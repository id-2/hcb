import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
    static values = {
        className: String
    }
    static targets = ['element', 'label']
    toggle(event) {
        event.preventDefault()
        this.elementTarget.classList.toggle(this.classNameValue)
        if (this.labelTarget) {
            if (this.labelTarget.textContent === "Full Name") {
                this.labelTarget.textContent = "Display Name"
            } else {
                this.labelTarget.textContent = "Full Name"
            }
        }
    }
}