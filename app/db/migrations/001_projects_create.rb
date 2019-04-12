# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:projects) do
      primary_key :id

      String :name, unique: true, null: false
      String :repo_url, unique: true

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
