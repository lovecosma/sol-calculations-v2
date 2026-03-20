import { Application } from "@hotwired/stimulus"
import TurboTriggerController from "../../../app/javascript/controllers/turbo_trigger_controller"

describe("TurboTriggerController", () => {
  let application
  let container
  let select
  let frame

  beforeEach(async () => {
    container = document.createElement("div")
    container.innerHTML = `
      <div
        data-controller="turbo-trigger"
        data-turbo-trigger-url-value="http://localhost/number_values"
        data-turbo-trigger-frame-id-value="test_frame"
      >
        <select name="number_type" data-action="change->turbo-trigger#trigger">
          <option value="">All Types</option>
          <option value="life_path">Life Path</option>
        </select>
      </div>
      <turbo-frame id="test_frame">
        <select name="number_value">
          <option value="">All Values</option>
          <option value="1">1</option>
        </select>
      </turbo-frame>
    `
    document.body.appendChild(container)

    select = container.querySelector("select[name='number_type']")
    frame = document.getElementById("test_frame")

    application = Application.start()
    application.register("turbo-trigger", TurboTriggerController)

    await Promise.resolve()
  })

  afterEach(() => {
    application.stop()
    document.body.removeChild(container)
  })

  describe("trigger()", () => {
    it("sets the frame src to the url with the input name and value as a param", () => {
      select.value = "life_path"
      select.dispatchEvent(new Event("change"))

      expect(frame.src).toBe("http://localhost/number_values?number_type=life_path")
    })

    it("disables the triggering select", () => {
      select.value = "life_path"
      select.dispatchEvent(new Event("change"))

      expect(select.disabled).toBe(true)
    })

    it("disables inputs inside the frame", () => {
      select.value = "life_path"
      select.dispatchEvent(new Event("change"))

      frame.querySelectorAll("select, input, button").forEach(el => {
        expect(el.disabled).toBe(true)
      })
    })

    it("re-enables the triggering select when the frame finishes loading", () => {
      select.value = "life_path"
      select.dispatchEvent(new Event("change"))

      frame.dispatchEvent(new CustomEvent("turbo:frame-load"))

      expect(select.disabled).toBe(false)
    })

    it("re-enables inputs inside the frame when the frame finishes loading", () => {
      select.value = "life_path"
      select.dispatchEvent(new Event("change"))

      frame.dispatchEvent(new CustomEvent("turbo:frame-load"))

      frame.querySelectorAll("select, input, button").forEach(el => {
        expect(el.disabled).toBe(false)
      })
    })

    it("only re-enables once after multiple triggers", () => {
      select.value = "life_path"
      select.dispatchEvent(new Event("change"))
      frame.dispatchEvent(new CustomEvent("turbo:frame-load"))

      select.value = "expression"
      select.dispatchEvent(new Event("change"))

      frame.dispatchEvent(new CustomEvent("turbo:frame-load"))
      frame.dispatchEvent(new CustomEvent("turbo:frame-load"))

      expect(select.disabled).toBe(false)
    })
  })
})
