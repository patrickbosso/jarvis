import { Controller } from "@hotwired/stimulus"

// Toggles which time-window chart pane / performance label / tab is active,
// and draws a Google-Finance-style crosshair + tooltip when hovering a chart.
export default class extends Controller {
  static targets = ["tab", "pane", "perf"]

  select(event) {
    this.show(event.currentTarget.dataset.window)
  }

  show(window) {
    this.tabTargets.forEach((t) =>
      t.classList.toggle("is-active", t.dataset.window === window)
    )
    this.paneTargets.forEach((p) => (p.hidden = p.dataset.window !== window))
    this.perfTargets.forEach((p) => (p.hidden = p.dataset.window !== window))
  }

  hover(event) {
    const wrap = event.currentTarget
    const prices = JSON.parse(wrap.dataset.prices || "[]")
    const times = JSON.parse(wrap.dataset.times || "[]")
    if (prices.length < 2) return

    const rect = wrap.getBoundingClientRect()
    const n = prices.length
    const frac = Math.min(Math.max((event.clientX - rect.left) / rect.width, 0), 1)
    const i = Math.round(frac * (n - 1))

    const min = Math.min(...prices)
    const max = Math.max(...prices)
    const span = max - min || 1
    const padTop = (8 / 110) * rect.height
    const plotH = rect.height - padTop * 2

    const px = (i / (n - 1)) * rect.width
    const py = padTop + (1 - (prices[i] - min) / span) * plotH

    const cross = wrap.querySelector(".snow-cross")
    const dot = wrap.querySelector(".snow-dot")
    const tip = wrap.querySelector(".snow-tip")

    cross.style.left = `${px}px`
    dot.style.left = `${px}px`
    dot.style.top = `${py}px`

    tip.textContent = this.formatTip(prices[i], times[i], wrap.dataset.window)
    // clamp tooltip within the chart bounds
    const half = tip.offsetWidth / 2
    tip.style.left = `${Math.min(Math.max(px, half + 2), rect.width - half - 2)}px`

    cross.style.display = "block"
    dot.style.display = "block"
    tip.style.display = "block"
  }

  leave(event) {
    const wrap = event.currentTarget
    ;[".snow-cross", ".snow-dot", ".snow-tip"].forEach((sel) => {
      const el = wrap.querySelector(sel)
      if (el) el.style.display = "none"
    })
  }

  formatTip(price, ts, window) {
    const value = new Intl.NumberFormat("fr-FR", {
      style: "currency",
      currency: "EUR",
      minimumFractionDigits: 2
    }).format(price)

    if (!ts) return value
    const d = new Date(ts * 1000)
    const intraday = window === "1D" || window === "1W"
    const when = intraday
      ? d.toLocaleString("fr-FR", { day: "2-digit", month: "short", hour: "2-digit", minute: "2-digit" })
      : d.toLocaleDateString("fr-FR", { day: "2-digit", month: "short", year: "numeric" })
    return `${value} · ${when}`
  }
}
