class WebhooksController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token

  def qonto
    payload = JSON.parse(request.body.read)

    user = User.first
    return head :ok unless user

    QontoWebhookJob.perform_later(user.id, payload)
    head :ok
  rescue JSON::ParserError
    head :bad_request
  end
end
