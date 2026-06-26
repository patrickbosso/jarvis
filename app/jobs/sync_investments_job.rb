class SyncInvestmentsJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    InvestmentService.new.sync_for_user(user)
    Rails.logger.info("[SyncInvestmentsJob] Synced investments for user #{user_id}")
  end
end
