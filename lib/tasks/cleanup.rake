namespace :cleanup do
  desc "Cleans up inactive Users from the database"
  task users: :environment do
    UsersCleanupJob.perform_now
  end

end
