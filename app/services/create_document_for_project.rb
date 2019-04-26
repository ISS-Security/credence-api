# frozen_string_literal: true

module Credence
  # Create new configuration for a project
  class CreateDocumentForProject
    def self.call(project_id:, document_data:)
      Project.first(id: project_id)
             .add_document(document_data)
    end
  end
end
