import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["province", "gst", "pst", "hst", "total"]
  static values = {
    subtotal: Number,
    currencyUnit: { type: String, default: "CAD" }
  }

  connect() {
    this.update()
  }

  update() {
    const province = this.provinceTarget.value
    const rates = this.taxRatesFor(province)

    const gstAmount = this.roundCurrency(this.subtotalValue * rates.gst)
    const pstAmount = this.roundCurrency(this.subtotalValue * rates.pst)
    const hstAmount = this.roundCurrency(this.subtotalValue * rates.hst)
    const total = this.roundCurrency(this.subtotalValue + gstAmount + pstAmount + hstAmount)

    this.gstTarget.textContent = this.formatCurrency(gstAmount)
    this.pstTarget.textContent = this.formatCurrency(pstAmount)
    this.hstTarget.textContent = this.formatCurrency(hstAmount)
    this.totalTarget.textContent = this.formatCurrency(total)
  }

  taxRatesFor(province) {
    switch (province) {
      case "ON":
        return { gst: 0.0, pst: 0.0, hst: 0.13 }
      case "NB":
      case "NL":
      case "PE":
        return { gst: 0.0, pst: 0.0, hst: 0.15 }
      case "NS":
        return { gst: 0.0, pst: 0.0, hst: 0.14 }
      case "BC":
      case "MB":
        return { gst: 0.05, pst: 0.07, hst: 0.0 }
      case "SK":
        return { gst: 0.05, pst: 0.06, hst: 0.0 }
      case "QC":
        return { gst: 0.05, pst: 0.09975, hst: 0.0 }
      default:
        return { gst: 0.05, pst: 0.0, hst: 0.0 }
    }
  }

  formatCurrency(amount) {
    return new Intl.NumberFormat("en-CA", {
      style: "currency",
      currency: this.currencyUnitValue
    }).format(amount)
  }

  roundCurrency(amount) {
    return Math.round(amount * 100) / 100
  }
}
