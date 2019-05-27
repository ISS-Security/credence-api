# frozen_string_literal: true

require_relative './app'

module Credence
  # Web controller for Credence API
  class Api < Roda
    route('documents') do |routing|
      unless @auth_account
        routing.halt 403, { message: 'Not authorized' }.to_json
      end

      @doc_route = "#{@api_root}/documents"

      # GET api/v1/documents/[doc_id]
      routing.on String do |doc_id|
        @req_document = Document.first(id: doc_id)

        routing.get do
          document = GetDocumentQuery.call(
            requestor: @auth_account, document: @req_document
          )

          { data: document }.to_json
        rescue GetDocumentQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetDocumentQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          puts "GET DOCUMENT ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end
    end
  end
end
