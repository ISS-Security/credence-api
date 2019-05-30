# frozen_string_literal: true

module Credence
  # Policy to determine if an account can view a particular project
  class CollaborationRequestPolicy
    def initialize(project, requestor_account, target_account, auth_scope = nil)
      @project = project
      @requestor_account = requestor_account
      @target_account = target_account
      @auth_scope = auth_scope
      @requestor = ProjectPolicy.new(requestor_account, project, auth_scope)
      @target = ProjectPolicy.new(target_account, project, auth_scope)
    end

    def can_invite?
      can_write? &&
        (@requestor.can_add_collaborators? && @target.can_collaborate?)
    end

    def can_remove?
      can_write? &&
        (@requestor.can_remove_collaborators? && target_is_collaborator?)
    end

    private

    def can_write?
      @auth_scope ? @auth_scope.can_write?('projects') : false
    end

    def target_is_collaborator?
      @project.collaborators.include?(@target_account)
    end
  end
end
