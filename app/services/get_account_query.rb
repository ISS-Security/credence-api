# frozen_string_literal: true

module Credence
  # Add a collaborator to another owner's existing project
  class GetAccountQuery
    # Error if requesting to see forbidden account
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that project'
      end
    end

    def self.call(requestor:, username:)
      account = Account.first(username: username)

      policy = AccountPolicy.new(requestor, account)
      policy.can_view? ? account : raise(ForbiddenError)
    end
  end
end
