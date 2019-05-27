# frozen_string_literal: true

module Credence
  # Policy to determine if an account can view a particular project
  class ProjectPolicy
    def initialize(account, project)
      @account = account
      @project = project
    end

    def can_view?
      account_is_owner? || account_is_collaborator?
    end

    # duplication is ok!
    def can_edit?
      account_is_owner? || account_is_collaborator?
    end

    def can_delete?
      account_is_owner?
    end

    def can_leave?
      account_is_collaborator?
    end

    def can_add_documents?
      account_is_owner? || account_is_collaborator?
    end

    def can_remove_documents?
      account_is_owner? || account_is_collaborator?
    end

    def can_add_collaborators?
      account_is_owner?
    end

    def can_remove_collaborators?
      account_is_owner?
    end

    def can_collaborate?
      not (account_is_owner? or account_is_collaborator?)
    end

    def summary
      {
        can_view: can_view?,
        can_edit: can_edit?,
        can_delete: can_delete?,
        can_leave: can_leave?,
        can_add_documents: can_add_documents?,
        can_delete_documents: can_remove_documents?,
        can_add_collaborators: can_add_collaborators?,
        can_remove_collaborators: can_remove_collaborators?,
        can_collaborate: can_collaborate?
      }
    end

    private

    def account_is_owner?
      @project.owner == @account
    end

    def account_is_collaborator?
      @project.collaborators.include?(@account)
    end
  end
end
