# frozen_string_literal: true

module Credence
  # Policy to determine if account can view a project
  class ProjectPolicy
    # Scope of project policies
    class AccountScope
      def initialize(current_account, target_account = nil)
        target_account ||= current_account
        @full_scope = all_projects(target_account)
        @current_account = current_account
        @target_account = target_account
      end

      def viewable
        if @current_account == @target_account
          @full_scope
        else
          @full_scope.select do |proj|
            includes_collaborator?(proj, @current_account)
          end
        end
      end

      private

      def all_projects(account)
        account.owned_projects + account.collaborations
      end

      def includes_collaborator?(project, account)
        project.collaborators.include? account
      end
    end
  end
end
