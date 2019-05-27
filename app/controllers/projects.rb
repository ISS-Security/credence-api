# frozen_string_literal: true

require_relative './app'

# rubocop:disable Metrics/BlockLength
module Credence
  # Web controller for Credence API
  class Api < Roda
    route('projects') do |routing|
      unauthorized_message = { message: 'Unauthorized Request' }.to_json
      routing.halt(403, unauthorized_message) unless @auth_account

      @proj_route = "#{@api_root}/projects"
      routing.on String do |proj_id|
        @req_project = Project.first(id: proj_id)

        # GET api/v1/projects/[ID]
        routing.get do
          project = GetProjectQuery.call(
            account: @auth_account, project: @req_project
          )

          { data: project }.to_json
        rescue GetProjectQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetProjectQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          puts "FIND PROJECT ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end

        routing.on('documents') do
          # POST api/v1/projects/[proj_id]/documents
          routing.post do
            new_document = CreateDocument.call(
              account: @auth_account,
              project: @req_project,
              document_data: JSON.parse(routing.body.read)
            )

            response.status = 201
            response['Location'] = "#{@doc_route}/#{new_document.id}"
            { message: 'Document saved', data: new_document }.to_json
          rescue CreateDocument::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue CreateDocument::IllegalRequestError => e
            routing.halt 400, { message: e.message }.to_json
          rescue StandardError => e
            puts "CREATE_DOCUMENT_ERROR: #{e.inspect}"
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end

        routing.on('collaborators') do # rubocop:disable Metrics/BlockLength
          # PUT api/v1/projects/[proj_id]/collaborators
          routing.put do
            req_data = JSON.parse(routing.body.read)

            collaborator = AddCollaborator.call(
              account: @auth_account,
              project: @req_project,
              collab_email: req_data['email']
            )

            { data: collaborator }.to_json
          rescue AddCollaborator::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
          end

          # DELETE api/v1/projects/[proj_id]/collaborators
          routing.delete do
            req_data = JSON.parse(routing.body.read)
            collaborator = RemoveCollaborator.call(
              req_username: @auth_account.username,
              collab_email: req_data['email'],
              project_id: proj_id
            )

            { message: "#{collaborator.username} removed from projet",
              data: collaborator }.to_json
          rescue RemoveCollaborator::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end
      end

      routing .is do
        # GET api/v1/projects
        routing.get do
          projects = ProjectPolicy::AccountScope.new(@auth_account).viewable

          JSON.pretty_generate(data: projects)
        rescue StandardError
          routing.halt 403, { message: 'Could not find any projects' }.to_json
        end

        # POST api/v1/projects
        routing.post do
          new_data = JSON.parse(routing.body.read)
          new_proj = @auth_account.add_owned_project(new_data)

          response.status = 201
          response['Location'] = "#{@proj_route}/#{new_proj.id}"
          { message: 'Project saved', data: new_proj }.to_json
        rescue Sequel::MassAssignmentRestriction
          routing.halt 400, { message: 'Illegal Request' }.to_json
        rescue StandardError
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
