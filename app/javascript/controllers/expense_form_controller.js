import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['field', 'button']
  static values = { enabled: { type: Boolean, default: false }, locked: { type: Boolean, default: false }  }

  connect() {
    for (const field of this.fieldTargets) {
      field.readOnly = !this.enabledValue

      field.addEventListener('dblclick', () => this.edit())
    }

    this.buttonTarget.addEventListener(
      'click',
      e => (this.enabledValue || e.preventDefault(), this.edit())
    )

    this.#buttons()
  }

  edit() {
    if (this.enabledValue || this.lockedValue) return
    this.enabledValue = true

    this.#buttons()

    for (const field of this.fieldTargets) {
      field.readOnly = false
    }

    this.editTarget.style.display = 'none'
    this.checkmarkTarget.style.display = 'block'
  }

  #buttons() {
    this.buttonTarget.querySelector('[aria-label=checkmark]').style.display =
      this.enabledValue && !this.lockedValue ? 'block' : 'none'
    this.buttonTarget.querySelector('[aria-label=edit]').style.display = this
      .enabledValue && !this.lockedValue
      ? 'none'
      : 'block'
  }
}
