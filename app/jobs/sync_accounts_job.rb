class SyncAccountsJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    QontoService.new.sync_for_user(user)
    # TinkService requires user_access_token from OAuth flow
    Rails.logger.info("[SyncAccountsJob] Synced accounts for user #{user_id}")
  end
end
