import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['input', 'picker', 'container']

  open = false

  connect() {
    document.addEventListener('click', this.handleDocumentClick.bind(this))
  }

  disconnect() {
    document.removeEventListener('click', this.handleDocumentClick.bind(this))
  }

  addEmoji(event) {
    this.inputTarget.value = event.detail.unicode;
    this.togglePicker();
  }

  togglePicker() {
    this.open = !this.open
    this.pickerTarget.style = `display: ${this.open ? "block" : "none"};`
  }

  handleDocumentClick(event) {
    if (!this.containerTarget.contains(event.target) && this.open == true) {
      this.togglePicker()
    }
  }
}
