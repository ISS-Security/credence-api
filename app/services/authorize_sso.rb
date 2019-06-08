# frozen_string_literal: true

require 'http'

module Credence
  # Find or create an SsoAccount based on Github code
  class AuthorizeSso
    def initialize(config)
      @config = config
    end

    def call(access_token)
      github_account = get_github_account(access_token)
      sso_account = find_or_create_sso_account(github_account)

      account_and_token(sso_account)
    end

    def get_github_account(access_token)
      gh_response = HTTP
        .headers(user_agent:    'Config Secure',
                 authorization: "token #{access_token}",
                 accept:        'application/json')
        .get(@config.GITHUB_ACCOUNT_URL)

      raise unless gh_response.status == 200

      account = GithubAccount.new(gh_response.parse)
      { username: account.username, email: account.email }
    end

    def find_or_create_sso_account(account_data)
      Account.first(email: account_data[:email]) ||
        Account.create_github_account(account_data)
    end

    def account_and_token(account)
      {
        type:       'sso_account',
        attributes: {
          account:    account,
          auth_token: AuthToken.create(account)
        }
      }
    end

    # Maps Github account details to attributes
    class GithubAccount
      def initialize(gh_account)
        @gh_account = gh_account
      end

      def username
        @gh_account['login'] + '@github'
      end

      def email
        @gh_account['email']
      end
    end
  end
end
