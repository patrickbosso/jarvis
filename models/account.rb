class Account < ApplicationRecord
  belongs_to :user

  enum :source, {
    qonto_sas: "qonto_sas",
    sg_perso: "sg_perso",
    trade_republic_pea: "trade_republic_pea"
  }

  validates :source, :balance_cents, :currency, presence: true

  after_initialize do
    self.currency ||= "EUR"
  end

  def balance_euros
    balance_cents / 100.0
  end
end
