# frozen_string_literal: true

module Credence
  # Add a collaborator to another owner's existing project
  class CreateDocument
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to add more documents'
      end
    end

    # Error for requests with illegal attributes
    class IllegalRequestError < StandardError
      def message
        'Cannot create a document with those attributes'
      end
    end

    def self.call(auth:, project:, document_data:)
      policy = ProjectPolicy.new(auth[:account], project, auth[:scope])
      raise ForbiddenError unless policy.can_add_documents?

      project.add_document(document_data)
    rescue Sequel::MassAssignmentRestriction
      raise IllegalRequestError
    end
  end
end
