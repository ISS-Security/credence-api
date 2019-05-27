# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  Credence::Document.map(&:destroy)
  Credence::Project.map(&:destroy)
  Credence::Account.map(&:destroy)
end

def auth_header(account_data)
  auth = Credence::AuthenticateAccount.call(
    username: account_data['username'],
    password: account_data['password']
  )

  "Bearer #{auth[:attributes][:auth_token]}"
end

DATA = {} # rubocop:disable Style/MutableConstant
DATA[:accounts] = YAML.load File.read('app/db/seeds/accounts_seed.yml')
DATA[:documents] = YAML.load File.read('app/db/seeds/documents_seed.yml')
DATA[:projects] = YAML.load File.read('app/db/seeds/projects_seed.yml')
DATA[:owners] = YAML.load File.read('app/db/seeds/owners_projects.yml')
