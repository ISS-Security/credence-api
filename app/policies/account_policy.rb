# frozen_string_literal: true

# Policy to determine if account can view a project
class AccountPolicy
  def initialize(request_account, account)
    @request_account = request_account
    @account = account
  end

  def can_view?
    self_request?
  end

  def can_edit?
    self_request?
  end

  def can_delete?
    self_request?
  end

  def summary
    {
      can_view: can_view?,
      can_edit: can_edit?,
      can_delete: can_delete?
    }
  end

  private

  def self_request?
    @request_account == @account
  end
end
