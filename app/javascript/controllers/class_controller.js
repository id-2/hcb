import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
    static values = {
        className: String
    }
    static targets = ['element']
    toggle(event) {
        event.preventDefault()
        this.elementTarget.classList.toggle(this.classNameValue)
    }
}