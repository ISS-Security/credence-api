# frozen_string_literal: true

require 'roda'
require_relative './app'

# rubocop:disable Metrics/BlockLength
module Credence
  # Web controller for Credence API
  class Api < Roda
    route('projects') do |routing|
      @proj_route = "#{@api_root}/projects"

      routing.on String do |proj_id|
        routing.on 'documents' do
          @doc_route = "#{@api_root}/projects/#{proj_id}/documents"
          # GET api/v1/projects/[proj_id]/documents/[doc_id]
          routing.get String do |doc_id|
            doc = Document.where(project_id: proj_id, id: doc_id).first
            doc ? doc.to_json : raise('Document not found')
          rescue StandardError => e
            routing.halt 404, { message: e.message }.to_json
          end

          # GET api/v1/projects/[proj_id]/documents
          routing.get do
            output = { data: Project.first(id: proj_id).documents }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt(404, { message: 'Could not find documents' }.to_json)
          end

          # POST api/v1/projects/[ID]/documents
          routing.post do
            new_data = JSON.parse(routing.body.read)

            new_doc = CreateDocumentForProject.call(
              project_id: proj_id, document_data: new_data
            )

            response.status = 201
            response['Location'] = "#{@doc_route}/#{new_doc.id}"
            { message: 'Document saved', data: new_doc }.to_json
          rescue Sequel::MassAssignmentRestriction
            routing.halt 400, { message: 'Illegal Request' }.to_json
          rescue StandardError
            routing.halt 500, { message: 'Database error' }.to_json
          end
        end

        # GET api/v1/projects/[ID]
        routing.get do
          proj = Project.first(id: proj_id)
          proj ? proj.to_json : raise('Project not found')
        rescue StandardError => e
          routing.halt 404, { message: e.message }.to_json
        end
      end

      # GET api/v1/projects
      routing.get do
        account = Account.first(username: @auth_account['username'])
        projects = account.projects
        JSON.pretty_generate(data: projects)
      rescue StandardError
        routing.halt 403, { message: 'Could not find any projects' }.to_json
      end

      # POST api/v1/projects
      routing.post do
        new_data = JSON.parse(routing.body.read)
        new_proj = Project.new(new_data)
        raise('Could not save project') unless new_proj.save

        response.status = 201
        response['Location'] = "#{@proj_route}/#{new_proj.id}"
        { message: 'Project saved', data: new_proj }.to_json
      rescue Sequel::MassAssignmentRestriction
        routing.halt 400, { message: 'Illegal Request' }.to_json
      rescue StandardError => e
        routing.halt 500, { message: e.message }.to_json
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
