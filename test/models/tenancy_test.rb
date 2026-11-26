require "test_helper"

class TenancyTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  class TenantProbeJob < ApplicationJob
    cattr_accessor :seen
    def perform(skill)
      self.class.seen = [ActsAsTenant.current_tenant, skill, Skill.count]
    end
  end

  setup do
    @crownstack = accounts(:crownstack)
    @infosys = accounts(:infosys)
  end

  test "records are scoped to the current tenant" do
    ActsAsTenant.with_tenant(@crownstack) do
      assert Skill.exists?(skills(:ruby).id)
      assert Skill.all.all? { |skill| skill.account_id == @crownstack.id }
    end
    ActsAsTenant.with_tenant(@infosys) do
      assert_not Skill.exists?(skills(:ruby).id)
    end
  end

  test "a tenant is required for scoped models" do
    ActsAsTenant.current_tenant = nil
    assert_raises(ActsAsTenant::Errors::NoTenantSet) { Skill.count }
    assert ActsAsTenant.without_tenant { Skill.count }.positive?
  end

  test "new records get the current tenant" do
    skill = ActsAsTenant.with_tenant(@crownstack) { Skill.create!(name: "Elixir") }
    assert_equal @crownstack, skill.account
  end

  test "a record cannot be created for another tenant" do
    ActsAsTenant.with_tenant(@crownstack) do
      skill = Skill.new(name: "Elixir", account: @infosys)
      assert_not skill.valid?
    end
  end

  test "a job enqueued inside a tenant runs in that tenant" do
    ActsAsTenant.with_tenant(@crownstack) { TenantProbeJob.perform_later(skills(:ruby)) }
    ActsAsTenant.current_tenant = nil

    perform_enqueued_jobs

    tenant, skill, count = TenantProbeJob.seen
    assert_equal @crownstack, tenant
    assert_equal skills(:ruby), skill
    assert_equal ActsAsTenant.with_tenant(@crownstack) { Skill.count }, count
  end

  test "the recurring cleanup jobs run per account without a tenant of their own" do
    ActsAsTenant.current_tenant = nil
    assert_nothing_raised { DeleteTimesheetsJob.perform_now }
    assert_nothing_raised { DeleteArchivedProjectsJob.perform_now }
  end
end
