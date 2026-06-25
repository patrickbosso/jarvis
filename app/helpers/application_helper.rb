module ApplicationHelper
  # Compact euro formatting used across the SnowUI dashboard.
  def eur(cents, compact: false)
    value = cents.to_i / 100.0
    if compact && value.abs >= 1000
      "#{(value / 1000.0).round(1).to_s.delete_suffix('.0')}k €"
    else
      number_to_currency(value, unit: "€", separator: ",", delimiter: " ", format: "%n %u", precision: 0)
    end
  end

  # Deterministic accent colour for an avatar based on a name.
  def avatar_color(name)
    palette = %w[#95A4FC #A8C5DA #B1E3FF #FF9F0A #34C759 #BF5AF2 #4C98FD #FF453A]
    palette[name.to_s.bytes.sum % palette.size]
  end

  def status_badge_class(status)
    case status.to_s
    when "in_progress" then "bg-blue-50 text-blue-800 border border-blue-200"
    when "feedback"    then "bg-amber-50 text-amber-800 border border-amber-200"
    when "delivered"   then "bg-green-50 text-green-800 border border-green-200"
    when "archived"    then "bg-gray-100 text-gray-500 border border-gray-200"
    else "bg-gray-100 text-gray-500 border border-gray-200"
    end
  end

  def suggestion_status_class(status)
    case status.to_s
    when "pending"   then "bg-amber-50 text-amber-800 border border-amber-200"
    when "validated" then "bg-green-50 text-green-800 border border-green-200"
    when "dismissed" then "bg-gray-100 text-gray-500 border border-gray-200"
    else "bg-gray-100 text-gray-500 border border-gray-200"
    end
  end
end
