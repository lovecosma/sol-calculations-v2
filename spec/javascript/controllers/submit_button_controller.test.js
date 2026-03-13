import { Application } from "@hotwired/stimulus"
import SubmitButtonController from "../../../app/javascript/controllers/submit_button_controller"

describe("SubmitButtonController", () => {
  let application
  let container
  let button
  let form

  beforeEach(() => {
    HTMLFormElement.prototype.requestSubmit = jest.fn()

    container = document.createElement("div")
    container.innerHTML = `
      <form>
        <button data-controller="submit-button" type="submit">Submit</button>
      </form>
    `
    document.body.appendChild(container)

    form = container.querySelector("form")
    button = container.querySelector("button")

    application = Application.start()
    application.register("submit-button", SubmitButtonController)
  })

  afterEach(() => {
    application.stop()
    document.body.removeChild(container)
  })

  describe("connect()", () => {
    it("finds the closest form", async () => {
      await Promise.resolve()
      expect(button.disabled).toBe(false)
    })
  })

  describe("on click", () => {
    it("disables the button on the next animation frame", async () => {
      await Promise.resolve()

      button.click()

      await new Promise(resolve => requestAnimationFrame(resolve))

      expect(button.disabled).toBe(true)
    })

    it("adds disabled styles on the next animation frame", async () => {
      await Promise.resolve()

      button.click()

      await new Promise(resolve => requestAnimationFrame(resolve))

      expect(button.classList.contains("opacity-50")).toBe(true)
      expect(button.classList.contains("cursor-not-allowed")).toBe(true)
    })
  })

  describe("on turbo:submit-end", () => {
    it("re-enables the button", async () => {
      await Promise.resolve()

      button.click()
      await new Promise(resolve => requestAnimationFrame(resolve))
      expect(button.disabled).toBe(true)

      form.dispatchEvent(new CustomEvent("turbo:submit-end"))

      expect(button.disabled).toBe(false)
    })

    it("removes disabled styles", async () => {
      await Promise.resolve()

      button.click()
      await new Promise(resolve => requestAnimationFrame(resolve))

      form.dispatchEvent(new CustomEvent("turbo:submit-end"))

      expect(button.classList.contains("opacity-50")).toBe(false)
      expect(button.classList.contains("cursor-not-allowed")).toBe(false)
    })
  })
})
