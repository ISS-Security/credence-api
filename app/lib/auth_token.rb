# frozen_string_literal: true

require 'base64'
require_relative 'securable'

## Token and Detokenize Authorization Information
# Usage examples:
#  token = AuthToken.create({ key: 'value', key2: 12 }, AuthToken::ONE_MONTH)
#  AuthToken.payload(token)   # => {"key"=>"value", "key2"=>12}
class AuthToken
  extend Securable

  ONE_HOUR = 60 * 60
  ONE_DAY = ONE_HOUR * 24
  ONE_WEEK = ONE_DAY * 7
  ONE_MONTH = ONE_WEEK * 4
  ONE_YEAR = ONE_MONTH * 12

  class ExpiredTokenError < StandardError; end
  class InvalidTokenError < StandardError; end

  # Create a token from a Hash payload
  def self.create(payload, scope = AuthScope.new, expiration = ONE_WEEK)
    tokenize(
      'payload' => payload,
      'scope' => scope,
      'exp' => expires(expiration)
    )
  end

  # Extract data from token
  def self.contents(token)
    contents = detokenize(token)
    expired?(contents) ? raise(ExpiredTokenError) : contents
  end

  # Tokenize contents or return nil if no data
  def self.tokenize(message)
    return nil unless message

    message_json = message.to_json
    ciphertext = base_encrypt(message_json)
    Base64.urlsafe_encode64(ciphertext)
  end

  # Detokenize and return contents, or raise error
  def self.detokenize(ciphertext64)
    return nil unless ciphertext64

    ciphertext = Base64.urlsafe_decode64(ciphertext64)
    message_json = base_decrypt(ciphertext)
    JSON.parse(message_json)
  rescue StandardError
    raise InvalidTokenError
  end

  def self.expires(expiration)
    (Time.now + expiration).to_i
  end

  def self.expired?(contents)
    Time.now > Time.at(contents['exp'])
  rescue StandardError
    raise InvalidTokenError
  end
end
