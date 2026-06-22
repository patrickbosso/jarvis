class SyncProjectsJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    NotionService.new.sync_for_user(user)
    Rails.logger.info("[SyncProjectsJob] Synced projects for user #{user_id}")
  end
end
