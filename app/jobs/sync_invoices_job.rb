class SyncInvoicesJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    TiimeService.new.sync_for_user(user)
    Rails.logger.info("[SyncInvoicesJob] Synced invoices for user #{user_id}")
  end
end
