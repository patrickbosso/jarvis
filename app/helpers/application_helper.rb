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

  # Build an SVG line chart from a price series. Returns an html_safe <svg>.
  # Stroke colour follows the period performance (green up / red down).
  def sparkline_svg(prices, up: true, width: 320, height: 110)
    prices = Array(prices).map(&:to_f)
    return "".html_safe if prices.size < 2

    pad_y    = 8.0
    min, max = prices.min, prices.max
    span     = (max - min).zero? ? 1.0 : (max - min)
    h        = height - pad_y * 2
    n        = prices.size

    points = prices.each_with_index.map do |v, i|
      x = (i.to_f / (n - 1)) * width
      y = pad_y + (1 - (v - min) / span) * h
      "#{x.round(2)},#{y.round(2)}"
    end

    base_y    = (pad_y + (1 - (prices.first - min) / span) * h).round(2)
    color     = up ? "var(--pos)" : "var(--neg)"
    line_path = points.join(" ")
    area      = "0,#{height} #{line_path} #{width},#{height}"

    <<~SVG.html_safe
      <svg class="snow-spark" viewBox="0 0 #{width} #{height}" preserveAspectRatio="none" width="100%" height="#{height}">
        <line x1="0" y1="#{base_y}" x2="#{width}" y2="#{base_y}" stroke="var(--line)" stroke-width="1" stroke-dasharray="3 4" vector-effect="non-scaling-stroke" />
        <polyline points="#{area}" fill="#{color}" fill-opacity="0.06" stroke="none" />
        <polyline points="#{line_path}" fill="none" stroke="#{color}" stroke-width="2" stroke-linejoin="round" stroke-linecap="round" vector-effect="non-scaling-stroke" />
      </svg>
    SVG
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
