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

    paid_this_year = current_user.invoices.paid.this_year.to_a
    @ca_ytd = paid_this_year.sum(&:amount_cents)
    @ca_year_target = @budget_rule ? @budget_rule.salary_target_cents * 12 : 0
    @ca_year_pct = @ca_year_target > 0 ? [(@ca_ytd.to_f / @ca_year_target * 100).round(1), 100].min : 0
    @ca_by_month = paid_this_year.group_by { |inv| inv.issued_at.month }
                                 .transform_values { |invs| invs.sum(&:amount_cents) }
    current_month = Date.today.month
    @ca_monthly_forecast = current_month > 0 ? (@ca_ytd / current_month) : 0
  end
end
