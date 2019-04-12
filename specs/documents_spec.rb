# frozen_string_literal: true

require_relative './spec_helper'

describe 'Test Document Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:projects].each do |project_data|
      Credence::Project.create(project_data)
    end
  end

  it 'HAPPY: should be able to get list of all documents' do
    proj = Credence::Project.first
    DATA[:documents].each do |doc|
      proj.add_document(doc)
    end

    get "api/v1/projects/#{proj.id}/documents"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single document' do
    doc_data = DATA[:documents][1]
    proj = Credence::Project.first
    doc = proj.add_document(doc_data).save

    get "/api/v1/projects/#{proj.id}/documents/#{doc.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal doc.id
    _(result['data']['attributes']['filename']).must_equal doc_data['filename']
  end

  it 'SAD: should return error if unknown document requested' do
    proj = Credence::Project.first
    get "/api/v1/projects/#{proj.id}/documents/foobar"

    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new documents' do
    proj = Credence::Project.first
    doc_data = DATA[:documents][1]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post "api/v1/projects/#{proj.id}/documents",
         doc_data.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.header['Location'].size).must_be :>, 0

    created = JSON.parse(last_response.body)['data']['data']['attributes']
    doc = Credence::Document.first

    _(created['id']).must_equal doc.id
    _(created['filename']).must_equal doc_data['filename']
    _(created['description']).must_equal doc_data['description']
  end
end
