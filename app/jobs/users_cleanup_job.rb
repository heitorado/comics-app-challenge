class UsersCleanupJob < ApplicationJob
  queue_as :default

  # Job dedicated to cleaning up old, inactive users from the database
  # An User is said to be old/inactive if its record had no activity in the past 2 days
  def perform
    inactive_users = User.inactive_for_more_than(2.days)
    inactive_users.destroy_all
  end
end