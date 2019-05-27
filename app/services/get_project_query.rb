# frozen_string_literal: true

module Credence
  # Add a collaborator to another owner's existing project
  class GetProjectQuery
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that project'
      end
    end

    # Error for cannot find a project
    class NotFoundError < StandardError
      def message
        'We could not find that project'
      end
    end

    def self.call(account:, project:)
      raise NotFoundError unless project

      policy = ProjectPolicy.new(account, project)
      raise ForbiddenError unless policy.can_view?

      project.full_details.merge(policies: policy.summary)
    end
  end
end
