# frozen_string_literal: true

require 'json'
require 'sequel'

module Credence
  # Models a project
  class Project < Sequel::Model
    many_to_one :owner, class: :'Credence::Account'

    many_to_many :collaborators,
                 class: :'Credence::Account',
                 join_table: :accounts_projects,
                 left_key: :project_id, right_key: :collaborator_id

    one_to_many :documents
    plugin :association_dependencies,
           documents: :destroy,
           collaborators: :nullify

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :name, :repo_url

    def to_h
      {
        type: 'project',
        attributes: {
          id: id,
          name: name,
          repo_url: repo_url
        }
      }
    end

    def full_details
      to_h.merge(
        relationships: {
          owner: owner,
          collaborators: collaborators,
          documents: documents
        }
      )
    end

    def to_json(options = {})
      JSON(to_h, options)
    end
  end
end
