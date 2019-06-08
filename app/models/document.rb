# frozen_string_literal: true

require 'json'
require 'sequel'

module Credence
  # Models a secret document
  class Document < Sequel::Model
    many_to_one :project

    plugin :uuid, field: :id
    plugin :timestamps, update_on_create: true

    plugin :whitelist_security
    set_allowed_columns :filename, :relative_path, :description, :content

    # Secure getters and setters
    def description
      SecureDB.decrypt(description_secure)
    end

    def description=(plaintext)
      self.description_secure = SecureDB.encrypt(plaintext)
    end

    def content
      SecureDB.decrypt(content_secure)
    end

    def content=(plaintext)
      self.content_secure = SecureDB.encrypt(plaintext)
    end

    def to_json(options = {})
      JSON(
        {
          type:       'document',
          attributes: public_attributes_hash,
          include:    includes_hash
        }, options
      )
    end

    def public_attributes_hash
      {
        id:            id,
        filename:      filename,
        relative_path: relative_path,
        description:   description,
        content:       content
      }
    end

    def includes_hash
      { project: project }
    end
  end
end
