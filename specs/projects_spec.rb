# frozen_string_literal: true

require_relative './spec_helper'

describe 'Test Project Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  it 'HAPPY: should be able to get list of all projects' do
    Credence::Project.create(DATA[:projects][0]).save
    Credence::Project.create(DATA[:projects][1]).save

    get 'api/v1/projects'
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single project' do
    existing_proj = DATA[:projects][1]
    Credence::Project.create(existing_proj).save
    id = Credence::Project.first.id

    get "/api/v1/projects/#{id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal id
    _(result['data']['attributes']['name']).must_equal existing_proj['name']
  end

  it 'SAD: should return error if unknown project requested' do
    get '/api/v1/projects/foobar'

    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new projects' do
    existing_proj = DATA[:projects][1]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post 'api/v1/projects', existing_proj.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.header['Location'].size).must_be :>, 0

    created = JSON.parse(last_response.body)['data']['data']['attributes']
    proj = Credence::Project.first

    _(created['id']).must_equal proj.id
    _(created['name']).must_equal existing_proj['name']
    _(created['repo_url']).must_equal existing_proj['repo_url']
  end
end
