class DashboardsController < ApplicationController
  def show
    @qonto = current_user.accounts.find_by(source: "qonto_sas")
    @sg_perso = current_user.accounts.find_by(source: "sg_perso")
    @pea = current_user.accounts.find_by(source: "trade_republic_pea")

    @invoices_paid_this_month = current_user.invoices.paid.this_month
    @invoices_sent = current_user.invoices.sent
    @invoices_overdue = current_user.invoices.overdue
    @projects_active = current_user.projects.active.order(:title)

    @ca_month = @invoices_paid_this_month.sum(:amount_cents)
    @ca_previsionnel = @invoices_sent.sum(:amount_cents)
    @ca_overdue = @invoices_overdue.sum(:amount_cents)

    @suggestion = current_user.transfer_suggestions.pending.order(suggested_at: :desc).first
    @budget_rule = current_user.budget_rule
  end
end
