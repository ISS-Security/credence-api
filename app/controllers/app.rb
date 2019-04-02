# frozen_string_literal: true

require 'roda'
require 'json'

require_relative '../models/document'

module Credence
  # Web controller for Credence API
  class Api < Roda
    plugin :environments
    plugin :halt

    configure do
      Document.setup
    end

    route do |routing| # rubocop:disable Metrics/BlockLength
      response['Content-Type'] = 'application/json'

      routing.root do
        { message: 'CredenceAPI up at /api/v1' }.to_json
      end

      routing.on 'api' do
        routing.on 'v1' do
          routing.on 'documents' do
            # GET api/v1/documents/[id]
            routing.get String do |id|
              Document.find(id).to_json
            rescue StandardError
              routing.halt 404, { message: 'Document not found' }.to_json
            end

            # GET api/v1/documents
            routing.get do
              output = { document_ids: Document.all }
              JSON.pretty_generate(output)
            end

            # POST api/v1/documents
            routing.post do
              new_data = JSON.parse(routing.body.read)
              new_doc = Document.new(new_data)

              if new_doc.save
                response.status = 201
                { message: 'Document saved', id: new_doc.id }.to_json
              else
                routing.halt 400, { message: 'Could not save document' }.to_json
              end
            end
          end
        end
      end
    end
  end
end
