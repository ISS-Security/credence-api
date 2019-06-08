# frozen_string_literal: true

require 'rbnacl'
require 'base64'

# Parses Json information as needed
class SignedRequest
  extend Securable

  class VerificationError < StandardError; end

  def initialize(config)
    @verify_key = Base64.strict_decode64(config.VERIFY_KEY)
    @signing_key = Base64.strict_decode64(config.SIGNING_KEY)
  end

  def self.generate_keypair
    signing_key = RbNaCl::SigningKey.generate
    verify_key = signing_key.verify_key

    { signing_key: Base64.strict_encode64(signing_key),
      verify_key:  Base64.strict_encode64(verify_key) }
  end

  def parse(signed_json)
    parsed = JSON.parse(signed_json, symbolize_names: true)
    parsed[:data] if verify(parsed[:data], parsed[:signature])
  end

  # Signing for internal tests (should be same as client method)
  def sign(message)
    signature = RbNaCl::SigningKey.new(@signing_key)
      .sign(message.to_json)
      .then { |sig| Base64.strict_encode64(sig) }

    { data: message, signature: signature }
  end

  private

  def verify(message, signature64)
    signature = Base64.strict_decode64(signature64)
    verifier = RbNaCl::VerifyKey.new(@verify_key)
    verifier.verify(signature, message.to_json)
  rescue StandardError
    raise VerificationError
  end
end
