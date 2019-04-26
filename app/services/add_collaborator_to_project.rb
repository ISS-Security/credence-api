# frozen_string_literal: true

module Credence
  # Add a collaborator to another owner's existing project
  class AddCollaboratorToProject
    def self.call(email:, project_id:)
      collaborator = Account.first(email: email)
      project = Project.first(id: project_id)
      return false if project.owner.id == collaborator.id

      project.add_collaborator
      collaborator
    end
  end
end
