# frozen_string_literal: true

module Credence
  # Add a collaborator to another owner's existing project
  class AddCollaborator
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to invite that person as collaborator'
      end
    end

    def self.call(account:, project:, collab_email:)
      invitee = Account.first(email: collab_email)
      policy = CollaborationRequestPolicy.new(project, account, invitee)
      raise ForbiddenError unless policy.can_invite?

      project.add_collaborator(invitee)
      invitee
    end
  end
end
