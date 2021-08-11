require "test_helper"

class UsersCleanupJobTest < ActiveJob::TestCase
  def setup
    @recent_user = User.create
    @inactive_user_1 = User.create
    @inactive_user_2 = User.create

    @inactive_user_1.update(updated_at: 3.days.ago)
    @inactive_user_2.update(updated_at: 1.month.ago)
  end

  test 'should only remove users whose records were not updated in the past 2 days' do
    assert_difference 'User.count', -2 do
      UsersCleanupJob.perform_now
    end
  end
end
