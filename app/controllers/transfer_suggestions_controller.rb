class TransferSuggestionsController < ApplicationController
  def index
    @suggestions = current_user.transfer_suggestions.order(suggested_at: :desc).limit(30)
  end

  def update
    @suggestion = current_user.transfer_suggestions.find(params[:id])
    case params[:action_type]
    when "validate"
      @suggestion.update!(status: "validated")
      redirect_to root_path, notice: "Virements validés."
    when "dismiss"
      @suggestion.update!(status: "dismissed")
      redirect_to root_path, notice: "Suggestion ignorée."
    else
      redirect_to root_path
    end
  end
end
