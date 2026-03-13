import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.form = this.element.closest("form")
    if (!this.form) return

    this.element.addEventListener("click", this.handleClick)
    this.form.addEventListener("turbo:submit-end", this.enable)
  }

  disconnect() {
    if (!this.form) return

    this.element.removeEventListener("click", this.handleClick)
    this.form.removeEventListener("turbo:submit-end", this.enable)
  }

  handleClick = () => {
    requestAnimationFrame(this.disable)
  }

  disable = () => {
    this.element.disabled = true
    this.element.classList.add("opacity-50", "cursor-not-allowed")
  }

  enable = () => {
    this.element.disabled = false
    this.element.classList.remove("opacity-50", "cursor-not-allowed")
  }
}
