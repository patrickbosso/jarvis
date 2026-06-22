class DailySummaryJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)

    calculator = BudgetCalculator.new(user)
    transfers = calculator.calculate

    suggestion = user.transfer_suggestions.create!(
      suggested_at: Time.current,
      status: "pending",
      trigger: "scheduled_daily",
      transfers_json: transfers
    )

    dashboard_url = Rails.application.routes.url_helpers.root_url(
      host: ENV.fetch("APP_HOST", "localhost:3000")
    )
    NotificationService.new.send_jarvis_summary(user, transfers, dashboard_url)

    Rails.logger.info("[DailySummaryJob] Created suggestion #{suggestion.id} for user #{user_id}")
  end
end
