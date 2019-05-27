# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Document Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    @account_data = DATA[:accounts][0]
    @wrong_account_data = DATA[:accounts][1]

    @account = Credence::Account.create(@account_data)
    @account.add_owned_project(DATA[:projects][0])
    @account.add_owned_project(DATA[:projects][1])
    Credence::Account.create(@wrong_account_data)

    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Getting a single document' do
    it 'HAPPY: should be able to get details of a single document' do
      doc_data = DATA[:documents][0]
      proj = @account.projects.first
      doc = proj.add_document(doc_data)

      header 'AUTHORIZATION', auth_header(@account_data)
      get "/api/v1/documents/#{doc.id}"
      _(last_response.status).must_equal 200

      result = JSON.parse(last_response.body)['data']
      _(result['attributes']['id']).must_equal doc.id
      _(result['attributes']['filename']).must_equal doc_data['filename']
    end

    it 'SAD AUTHORIZATION: should not get details without authorization' do
      doc_data = DATA[:documents][1]
      proj = Credence::Project.first
      doc = proj.add_document(doc_data)

      get "/api/v1/documents/#{doc.id}"

      result = JSON.parse last_response.body

      _(last_response.status).must_equal 403
      _(result['attributes']).must_be_nil
    end

    it 'BAD AUTHORIZATION: should not get details with wrong authorization' do
      doc_data = DATA[:documents][0]
      proj = @account.projects.first
      doc = proj.add_document(doc_data)

      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      get "/api/v1/documents/#{doc.id}"

      result = JSON.parse last_response.body

      _(last_response.status).must_equal 403
      _(result['attributes']).must_be_nil
    end

    it 'SAD: should return error if document does not exist' do
      header 'AUTHORIZATION', auth_header(@account_data)
      get '/api/v1/documents/foobar'

      _(last_response.status).must_equal 404
    end
  end

  describe 'Creating Documents' do
    before do
      @proj = Credence::Project.first
      @doc_data = DATA[:documents][1]
    end

    it 'HAPPY: should be able to create when everything correct' do
      header 'AUTHORIZATION', auth_header(@account_data)
      post "api/v1/projects/#{@proj.id}/documents", @doc_data.to_json
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      doc = Credence::Document.first

      _(created['id']).must_equal doc.id
      _(created['filename']).must_equal @doc_data['filename']
      _(created['description']).must_equal @doc_data['description']
    end

    it 'BAD AUTHORIZATION: should not create with incorrect authorization' do
      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      post "api/v1/projects/#{@proj.id}/documents", @doc_data.to_json

      data = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.header['Location']).must_be_nil
      _(data).must_be_nil
    end

    it 'SAD AUTHORIZATION: should not create without any authorization' do
      post "api/v1/projects/#{@proj.id}/documents", @doc_data.to_json

      data = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.header['Location']).must_be_nil
      _(data).must_be_nil
    end

    it 'BAD VULNERABILITY: should not create with mass assignment' do
      bad_data = @doc_data.clone
      bad_data['created_at'] = '1900-01-01'
      header 'AUTHORIZATION', auth_header(@account_data)
      post "api/v1/projects/#{@proj.id}/documents", bad_data.to_json

      data = JSON.parse(last_response.body)['data']
      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
      _(data).must_be_nil
    end
  end
end
