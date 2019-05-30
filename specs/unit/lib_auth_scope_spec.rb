# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AuthScope' do
  include Rack::Test::Methods

  it 'AUTH SCOPE: should validate default full scope' do
    scope = AuthScope.new
    _(scope.can_read?('*')).must_equal true
    _(scope.can_write?('*')).must_equal true
    _(scope.can_read?('document')).must_equal true
    _(scope.can_write?('document')).must_equal true
  end

  it 'AUTH SCOPE: should evalutate read-only scope' do
    scope = AuthScope.new(AuthScope::READ_ONLY)
    _(scope.can_read?('documents')).must_equal true
    _(scope.can_read?('projects')).must_equal true
    _(scope.can_write?('documents')).must_equal false
    _(scope.can_write?('projects')).must_equal false
  end

  it 'AUTH SCOPE: should validate single limited scope' do
    scope = AuthScope.new('documents:read')
    _(scope.can_read?('*')).must_equal false
    _(scope.can_write?('*')).must_equal false
    _(scope.can_read?('documents')).must_equal true
    _(scope.can_write?('documents')).must_equal false
  end

  it 'AUTH SCOPE: should validate list of limited scopes' do
    scope = AuthScope.new('projects:read documents:write')
    _(scope.can_read?('*')).must_equal false
    _(scope.can_write?('*')).must_equal false
    _(scope.can_read?('projects')).must_equal true
    _(scope.can_write?('projects')).must_equal false
    _(scope.can_read?('documents')).must_equal true
    _(scope.can_write?('documents')).must_equal true
  end
end
