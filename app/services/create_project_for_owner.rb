# frozen_string_literal: true

module Credence
  # Service object to create a new project for an owner
  class CreateProjectForOwner
    def self.call(owner_id:, project_data:)
      Account.find(id: owner_id)
             .add_owned_project(project_data)
    end
  end
end
