class InvestmentService
  YAHOO_BASE = "https://query1.finance.yahoo.com"

  # Display window => Yahoo (range, interval). Order matters: 1D drives the
  # current price / day change shown on the card.
  WINDOWS = {
    "1D"  => { range: "1d",  interval: "5m"  },
    "1W"  => { range: "5d",  interval: "30m" },
    "1M"  => { range: "1mo", interval: "1d"  },
    "YTD" => { range: "ytd", interval: "1d"  },
    "5Y"  => { range: "5y",  interval: "1wk" },
    "Max" => { range: "max", interval: "1mo" }
  }.freeze

  def initialize
    @conn = Faraday.new(YAHOO_BASE) do |f|
      f.request :retry, max: 2, interval: 0.5
      f.headers["User-Agent"] = "Mozilla/5.0"
    end
  end

  def sync_for_user(user)
    user.investments.each do |investment|
      sync_one(investment)
    rescue => e
      Rails.logger.error("[InvestmentService] #{investment.yahoo_ticker}: #{e.message}")
    end
  end

  def sync_one(investment)
    chart = {}
    day_meta = nil

    WINDOWS.each do |label, opts|
      result = fetch_chart(investment.yahoo_ticker, opts[:range], opts[:interval])
      next unless result

      day_meta ||= result[:meta] if label == "1D"
      prices = result[:prices]
      times  = result[:times]
      next if prices.size < 2

      pct =
        if label == "1D" && result[:meta]["chartPreviousClose"].to_f > 0
          ref = result[:meta]["chartPreviousClose"].to_f
          ((prices.last - ref) / ref * 100).round(2)
        else
          ((prices.last - prices.first) / prices.first * 100).round(2)
        end

      chart[label] = { "p" => prices.map { |v| v.round(4) }, "t" => times, "pct" => pct }
    end

    return if chart.empty?

    meta = day_meta || fetch_chart(investment.yahoo_ticker, "1d", "1d")&.dig(:meta)
    investment.update!(
      last_price_cents: to_cents(meta&.dig("regularMarketPrice") || chart.dig("1D", "p")&.last),
      prev_close_cents: to_cents(meta&.dig("chartPreviousClose")),
      chart_json:       chart,
      last_fetched_at:  Time.current
    )
  end

  private

  def fetch_chart(ticker, range, interval)
    response = @conn.get("/v8/finance/chart/#{ticker}", { range: range, interval: interval })
    return nil unless response.status == 200

    body   = JSON.parse(response.body)
    result = body.dig("chart", "result", 0)
    return nil unless result

    closes     = result.dig("indicators", "quote", 0, "close") || []
    timestamps = result["timestamp"] || []
    # Keep timestamp/close pairs aligned, dropping gaps where close is nil.
    pairs  = closes.each_with_index.filter_map { |c, i| [timestamps[i], c] if c }
    return nil if pairs.empty?

    { meta: result["meta"] || {}, prices: pairs.map(&:last), times: pairs.map(&:first) }
  rescue Faraday::Error, JSON::ParserError => e
    Rails.logger.error("[InvestmentService] fetch #{ticker} #{range}: #{e.message}")
    nil
  end

  def to_cents(value)
    return nil unless value
    (value.to_f * 100).round
  end
end
