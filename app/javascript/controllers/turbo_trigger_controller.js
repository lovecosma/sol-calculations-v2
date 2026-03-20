import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String, frameId: String }

  trigger(event) {
    const url = new URL(this.urlValue, window.location.origin)
    url.searchParams.set(event.target.name, event.target.value)

    const frame = document.getElementById(this.frameIdValue)
    this.setDisabled(event.target, frame, true)
    frame.addEventListener("turbo:frame-load", () => this.setDisabled(event.target, frame, false), { once: true })

    frame.src = url.toString()
  }

  setDisabled(trigger, frame, disabled) {
    trigger.disabled = disabled
    frame.querySelectorAll("select, input, button").forEach(el => el.disabled = disabled)
  }
}
