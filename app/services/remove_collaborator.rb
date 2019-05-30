# frozen_string_literal: true

module Credence
  # Add a collaborator to another owner's existing project
  class RemoveCollaborator
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to remove that person'
      end
    end

    def self.call(auth:, collab_email:, project_id:)
      project = Project.first(id: project_id)
      collaborator = Account.first(email: collab_email)

      policy = CollaborationRequestPolicy.new(
        project, auth[:account], collaborator, auth[:scope]
      )
      raise ForbiddenError unless policy.can_remove?

      project.remove_collaborator(collaborator)
      collaborator
    end
  end
end
