import { Controller } from '@hotwired/stimulus'

const konami = [
  'ArrowUp',
  'ArrowUp',
  'ArrowDown',
  'ArrowDown',
  'ArrowLeft',
  'ArrowRight',
  'ArrowLeft',
  'ArrowRight',
  'KeyB',
  'KeyA',
  'Enter'
]

export default class extends Controller {
  static values = {
    sequence: { type: Array, default: konami }
  }

  initialize() {
    this.index = -1
  }

  keydown(e) {
    if (e.code == this.sequenceValue[this.index + 1]) {
      this.index++
    } else {
      this.index = -1
    }

    if (this.index == this.sequenceValue.length - 1) {
      this.dispatch('completed')
      this.index = -1
    }
  }
}
