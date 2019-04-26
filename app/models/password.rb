# frozen_string_literal: true

require 'base64'
require_relative '../lib/key_stretch'

module Credence
  # Digests and checks passwords using salt and password-appropriate hash
  class Password
    extend KeyStretch

    def initialize(salt, digest)
      @salt = salt
      @digest = digest
    end

    def correct?(password)
      new_digest = Password.password_hash(@salt, password)
      @digest == new_digest
    end

    def to_json(options = {})
      JSON({ salt: Base64.strict_encode64(@salt),
             digest: Base64.strict_encode64(@digest) },
           options)
    end

    alias to_s to_json

    def self.digest(password)
      salt = new_salt
      digest = password_hash(salt, password)
      new(salt, digest)
    end

    def self.from_digest(digest)
      digested = JSON.parse(digest)
      salt = Base64.strict_decode64(digested['salt'])
      digest = Base64.strict_decode64(digested['digest'])
      new(salt, digest)
    end
  end
end
