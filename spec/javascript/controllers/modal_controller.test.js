import { Application } from "@hotwired/stimulus"
import ModalController from "../../../app/javascript/controllers/modal_controller"

describe("ModalController", () => {
  let application
  let container

  beforeEach(() => {
    container = document.createElement("div")
    container.innerHTML = `
      <div data-controller="modal" id="test-modal">
        <button data-action="click->modal#open">Open</button>
        <div class="hidden" data-modal-target="container" data-action="click->modal#closeOnClickOutside">
          <div class="modal-content">
            <button data-action="click->modal#close">Close</button>
            <p>Modal Content</p>
          </div>
        </div>
      </div>
    `
    document.body.appendChild(container)

    application = Application.start()
    application.register("modal", ModalController)
  })

  afterEach(() => {
    application.stop()
    document.body.removeChild(container)
  })

  describe("targets", () => {
    it("defines container target", () => {
      expect(ModalController.targets).toContain("container")
    })
  })

  describe("open()", () => {
    it("removes hidden class from container", () => {
      const modalContainer = container.querySelector('[data-modal-target="container"]')
      const openButton = container.querySelector('[data-action="click->modal#open"]')

      expect(modalContainer.classList.contains("hidden")).toBe(true)

      openButton.click()

      expect(modalContainer.classList.contains("hidden")).toBe(false)
    })
  })

  describe("close()", () => {
    it("adds hidden class to container", () => {
      const modalContainer = container.querySelector('[data-modal-target="container"]')
      const openButton = container.querySelector('[data-action="click->modal#open"]')
      const closeButton = container.querySelector('[data-action="click->modal#close"]')

      openButton.click()
      expect(modalContainer.classList.contains("hidden")).toBe(false)

      closeButton.click()
      expect(modalContainer.classList.contains("hidden")).toBe(true)
    })
  })

  describe("closeOnClickOutside()", () => {
    it("closes modal when clicking on backdrop", () => {
      const modalContainer = container.querySelector('[data-modal-target="container"]')
      const openButton = container.querySelector('[data-action="click->modal#open"]')

      openButton.click()
      expect(modalContainer.classList.contains("hidden")).toBe(false)

      modalContainer.click()

      expect(modalContainer.classList.contains("hidden")).toBe(true)
    })

    it("does not close modal when clicking inside content", () => {
      const modalContainer = container.querySelector('[data-modal-target="container"]')
      const modalContent = container.querySelector('.modal-content')
      const openButton = container.querySelector('[data-action="click->modal#open"]')

      openButton.click()
      expect(modalContainer.classList.contains("hidden")).toBe(false)

      const clickEvent = new MouseEvent("click", { bubbles: true })
      Object.defineProperty(clickEvent, "target", { value: modalContent, enumerable: true })

      modalContainer.dispatchEvent(clickEvent)

      expect(modalContainer.classList.contains("hidden")).toBe(false)
    })
  })
})
