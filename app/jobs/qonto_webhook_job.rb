class QontoWebhookJob < ApplicationJob
  queue_as :critical

  def perform(user_id, payload)
    user = User.find(user_id)

    QontoService.new.sync_for_user(user)

    calculator = BudgetCalculator.new(user)
    transfers = calculator.calculate

    return if transfers.empty?

    suggestion = user.transfer_suggestions.create!(
      suggested_at: Time.current,
      status: "pending",
      trigger: "client_payment",
      transfers_json: transfers
    )

    dashboard_url = Rails.application.routes.url_helpers.root_url(
      host: ENV.fetch("APP_HOST", "localhost:3000")
    )

    amount = payload.dig("data", "amount") || "?"
    label = payload.dig("data", "label") || "un client"
    message = "Paiement reçu de #{label} (#{amount} €). #{BudgetCalculator.new(user).summary_text(transfers)}"

    Rushover.notify(
      token: ENV.fetch("PUSHOVER_APP_TOKEN"),
      user: ENV.fetch("PUSHOVER_USER_KEY"),
      message: message,
      title: "Jarvis — Paiement reçu",
      url: dashboard_url,
      url_title: "Voir le dashboard"
    )

    Rails.logger.info("[QontoWebhookJob] Processed payment webhook for user #{user_id}")
  rescue => e
    Rails.logger.error("[QontoWebhookJob] Error: #{e.message}")
    raise
  end
end
