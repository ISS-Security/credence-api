# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'

module Credence
  # Holds a full secret document
  class Document
    STORE_DIR = 'app/db/store/'

    # Create a new document by passing in hash of attributes
    def initialize(new_document)
      @id          = new_document['id'] || new_id
      @filename    = new_document['filename']
      @description = new_document['description']
      @content     = new_document['content']
    end

    attr_reader :id, :filename, :description, :content

    def to_json(options = {})
      JSON(
        {
          type: 'document',
          id: id,
          filename: filename,
          description: description,
          content: content
        },
        options
      )
    end

    # File store must be setup once when application runs
    def self.setup
      Dir.mkdir(STORE_DIR) unless Dir.exist? STORE_DIR
    end

    # Stores document in file store
    def save
      File.write(STORE_DIR + id + '.txt', to_json)
    end

    # Query method to find one document
    def self.find(find_id)
      document_file = File.read(STORE_DIR + find_id + '.txt')
      Document.new JSON.parse(document_file)
    end

    # Query method to retrieve index of all documents
    def self.all
      Dir.glob(STORE_DIR + '*.txt').map do |file|
        file.match(/#{Regexp.quote(STORE_DIR)}(.*)\.txt/)[1]
      end
    end

    private

    def new_id
      timestamp = Time.now.to_f.to_s
      Base64.urlsafe_encode64(RbNaCl::Hash.sha256(timestamp))[0..9]
    end
  end
end
