class Investment < ApplicationRecord
  belongs_to :user

  WINDOW_LABELS = { "1D" => "1J", "1W" => "1S", "1M" => "1M", "YTD" => "YTD", "5Y" => "5A", "Max" => "Max" }.freeze

  # Ordered list of windows that actually have data, e.g. [["1D","1J"], ...]
  def available_windows
    WINDOW_LABELS.filter_map do |key, label|
      [key, label] if chart_json.is_a?(Hash) && chart_json[key].present?
    end
  end

  def window_prices(key)
    Array(chart_json&.dig(key, "p"))
  end

  def window_times(key)
    Array(chart_json&.dig(key, "t"))
  end

  def window_pct(key)
    chart_json&.dig(key, "pct")
  end

  def has_chart?
    chart_json.is_a?(Hash) && chart_json.any?
  end

  def current_value_cents
    return 0 unless last_price_cents && shares
    (last_price_cents * shares).round
  end

  def cost_basis_cents
    return 0 unless avg_price_cents && shares
    (avg_price_cents * shares).round
  end

  def pnl_cents
    current_value_cents - cost_basis_cents
  end

  def pnl_pct
    return 0 if cost_basis_cents.zero?
    (pnl_cents.to_f / cost_basis_cents * 100).round(2)
  end

  def day_change_cents
    return 0 unless last_price_cents && prev_close_cents && shares
    ((last_price_cents - prev_close_cents) * shares).round
  end

  def day_change_pct
    return 0 unless last_price_cents && prev_close_cents && prev_close_cents > 0
    ((last_price_cents - prev_close_cents).to_f / prev_close_cents * 100).round(2)
  end

  def price_euros
    last_price_cents.to_i / 100.0
  end

  def stale?
    last_fetched_at.nil? || last_fetched_at < 1.hour.ago
  end
end
