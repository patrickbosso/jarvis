class BudgetCalculator
  def initialize(user)
    @user = user
    @rule = user.budget_rule
  end

  def calculate
    return [] unless @rule

    qonto = @user.accounts.find_by(source: "qonto_sas")
    return [] unless qonto

    qonto_balance = qonto.balance_cents
    available = qonto_balance - @rule.fixed_charges_cents

    return [] if available <= 0

    transfers = []

    if available >= @rule.salary_target_cents
      transfers << {
        label: "SAS → EI (salaire)",
        amount_cents: @rule.salary_target_cents,
        from: "qonto_sas",
        to: "ei"
      }

      remaining = available - @rule.salary_target_cents

      if remaining >= @rule.savings_target_cents
        transfers << {
          label: "EI → Compte perso (épargne)",
          amount_cents: @rule.savings_target_cents,
          from: "ei",
          to: "sg_perso"
        }

        surplus = remaining - @rule.savings_target_cents
        if surplus > 0
          transfers << {
            label: "Compte perso → PEA Trade Republic",
            amount_cents: surplus,
            from: "sg_perso",
            to: "trade_republic"
          }
        end
      else
        transfers << {
          label: "EI → Compte perso (épargne partielle)",
          amount_cents: [remaining, 0].max,
          from: "ei",
          to: "sg_perso"
        }
      end
    end

    transfers
  end

  def summary_text(transfers)
    return "Solde insuffisant pour effectuer des virements." if transfers.empty?

    lines = transfers.map do |t|
      "• #{t[:label]} : #{format_amount(t[:amount_cents])}"
    end

    "Voici les virements suggérés :\n#{lines.join("\n")}"
  end

  private

  def format_amount(cents)
    "#{(cents / 100.0).to_i} €"
  end
end
