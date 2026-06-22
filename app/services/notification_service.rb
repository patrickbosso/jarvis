class NotificationService
  def send_jarvis_summary(user, transfers, dashboard_url)
    calculator = BudgetCalculator.new(user)
    message = calculator.summary_text(transfers)

    Rushover.notify(
      token: ENV.fetch("PUSHOVER_APP_TOKEN"),
      user: ENV.fetch("PUSHOVER_USER_KEY"),
      message: message,
      title: "Jarvis — Résumé du jour",
      url: dashboard_url,
      url_title: "Voir le dashboard"
    )
  rescue => e
    Rails.logger.error("[NotificationService] Pushover error: #{e.message}")
  end
end
