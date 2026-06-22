class BudgetRulesController < ApplicationController
  def edit
    @budget_rule = current_user.budget_rule || current_user.build_budget_rule
  end

  def update
    @budget_rule = current_user.budget_rule || current_user.build_budget_rule
    if @budget_rule.update(budget_rule_params)
      redirect_to root_path, notice: "Règles budgétaires mises à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def budget_rule_params
    raw = params.require(:budget_rule).permit(
      :salary_target_cents,
      :mortgage_amount_cents,
      :living_expenses_cents,
      :savings_target_cents,
      :freelance_budget_cents
    )
    # Form sends values in euros; convert to cents
    raw.transform_values { |v| (v.to_f * 100).to_i }
  end
end
