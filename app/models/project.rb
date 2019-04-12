# frozen_string_literal: true

require 'json'
require 'sequel'

module Credence
  # Models a project
  class Project < Sequel::Model
    one_to_many :documents
    plugin :association_dependencies, documents: :destroy

    plugin :timestamps

    # rubocop:disable MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'project',
            attributes: {
              id: id,
              name: name,
              repo_url: repo_url
            }
          }
        }, options
      )
    end
    # rubocop:enable MethodLength
  end
end
