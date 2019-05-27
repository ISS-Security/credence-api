# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AddCollaborator service' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      Credence::Account.create(account_data)
    end

    project_data = DATA[:projects].first

    @owner = Credence::Account.all[0]
    @collaborator = Credence::Account.all[1]
    @project = Credence::CreateProjectForOwner.call(
      owner_id: @owner.id, project_data: project_data
    )
  end

  it 'HAPPY: should be able to add a collaborator to a project' do
    Credence::AddCollaborator.call(
      account: @owner,
      project: @project,
      collab_email: @collaborator.email
    )

    _(@collaborator.projects.count).must_equal 1
    _(@collaborator.projects.first).must_equal @project
  end

  it 'BAD: should not add owner as a collaborator' do
    proc {
      Credence::AddCollaborator.call(
        account: @owner,
        project: @project,
        collab_email: @owner.email
      )
    }.must_raise Credence::AddCollaborator::ForbiddenError
  end
end
