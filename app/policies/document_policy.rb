# frozen_string_literal: true

# Policy to determine if account can view a project
class DocumentPolicy
  def initialize(account, document, auth_scope = nil)
    @account = account
    @document = document
    @auth_scope = auth_scope
  end

  def can_view?
    can_read? && (account_owns_project? || account_collaborates_on_project?)
  end

  def can_edit?
    can_write? && (account_owns_project? || account_collaborates_on_project?)
  end

  def can_delete?
    can_write? && (account_owns_project? || account_collaborates_on_project?)
  end

  def summary
    {
      can_view: can_view?,
      can_edit: can_edit?,
      can_delete: can_delete?
    }
  end

  private

  def can_read?
    @auth_scope ? @auth_scope.can_read?('documents') : false
  end

  def can_write?
    @auth_scope ? @auth_scope.can_write?('documents') : false
  end

  def account_owns_project?
    @document.project.owner == @account
  end

  def account_collaborates_on_project?
    @document.project.collaborators.include?(@account)
  end
end
