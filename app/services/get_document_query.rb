# frozen_string_literal: true

module Credence
  # Add a collaborator to another owner's existing project
  class GetDocumentQuery
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that document'
      end
    end

    # Error for cannot find a project
    class NotFoundError < StandardError
      def message
        'We could not find that document'
      end
    end

    # Document for given requestor account
    def self.call(requestor:, document:)
      raise NotFoundError unless document

      policy = DocumentPolicy.new(requestor, document)
      raise ForbiddenError unless policy.can_view?

      document
    end
  end
end
