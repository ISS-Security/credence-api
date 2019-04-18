# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Document Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:projects].each do |project_data|
      Credence::Project.create(project_data)
    end
  end

  it 'HAPPY: should retrieve correct data from database' do
    doc_data = DATA[:documents][1]
    proj = Credence::Project.first
    new_doc = proj.add_document(doc_data)

    doc = Credence::Document.find(id: new_doc.id)
    _(doc.filename).must_equal new_doc.filename
    _(doc.relative_path).must_equal new_doc.relative_path
    _(doc.description).must_equal new_doc.description
    _(doc.content).must_equal new_doc.content
  end

  it 'SECURITY: should not use deterministic integers' do
    doc_data = DATA[:documents][1]
    proj = Credence::Project.first
    new_doc = proj.add_document(doc_data)

    _(new_doc.id).wont_be_instance_of Integer
    _(proc { new_doc.id - new_doc.id }).must_raise NoMethodError
  end

  it 'SECURITY: should secure sensitive attributes' do
    doc_data = DATA[:documents][1]
    proj = Credence::Project.first
    new_doc = proj.add_document(doc_data)
    stored_doc = app.DB[:documents].first

    _(stored_doc[:description_secure]).wont_equal new_doc.description
    _(stored_doc[:content_secure]).wont_equal new_doc.content
  end
end
