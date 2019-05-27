# frozen_string_literal: true

module Credence
  # Methods for controllers to mixin
  module SecureRequestHelpers
    class UnauthorizedRequestError < StandardError; end
    class NotFoundError < StandardError; end

    def secure_request?(routing)
      routing.scheme.casecmp(Api.config.SECURE_SCHEME).zero?
    end

    def authenticated_account(headers)
      return nil unless headers['AUTHORIZATION']

      scheme, auth_token = headers['AUTHORIZATION'].split(' ')
      return nil unless scheme.match?(/^Bearer$/i)

      account_payload = AuthToken.payload(auth_token)
      Account.first(username: account_payload['attributes']['username'])
    end
  end
end
