# frozen_string_literal: true

require 'roda'
require 'econfig'

module Credence
  # Configuration for the API
  class Api < Roda
    plugin :environments

    extend Econfig::Shortcut
    Econfig.env = environment.to_s
    Econfig.root = '.'

    configure :development, :test do
      # Allows running reload! in pry to restart entire app
      def self.reload!
        exec 'pry -r ./specs/test_load_all'
      end
    end

    configure :development, :test do
      ENV['DATABASE_URL'] = 'sqlite://' + config.DB_FILENAME
    end

    configure :production do
      # Production platform should specify DATABASE_URL environment variable
    end

    configure do
      require 'sequel'
      DB = Sequel.connect(ENV['DATABASE_URL'])

      def self.DB # rubocop:disable Naming/MethodName
        DB
      end
    end
  end
end
