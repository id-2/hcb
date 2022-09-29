import { Controller } from '@hotwired/stimulus'
import { autoUpdate, computePosition, flip, offset } from '@floating-ui/dom'
import $ from 'jquery'

export default class extends Controller {
  static targets = ['toggle', 'content']

  static values = {
    appendTo: String,
    placement: { type: String, default: 'bottom-start' }
  }

  initialize() {
    this.isOpen = false
  }

  disconnect() {
    this.cleanup && this.cleanup()
    this.content && this.content.remove()
  }

  toggle() {
    if (this.isOpen) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    if (!this.content) {
      this.content = this.contentTarget.cloneNode(true)
      ;(
        (this.appendToValue && document.querySelector(this.appendToValue)) ||
        document.body
      ).appendChild(this.content)
      Object.assign(this.content.style, {
        position: 'absolute',
        display: 'block',
        left: 0,
        top: 0
      })
    } else {
      Object.assign(this.content.style, {
        display: 'block'
      })
    }

    this.cleanup = autoUpdate(this.toggleTarget, this.content, () => {
      computePosition(this.toggleTarget, this.content, {
        placement: this.placementValue,
        middleware: [offset(5), flip({ padding: 5 })]
      }).then(({ x, y }) => {
        Object.assign(this.content.style, {
          top: `${y}px`,
          left: `${x}px`
        })
        this.toggleTarget.setAttribute('aria-expanded', true)
        this.isOpen = true

        this.content
          .querySelectorAll("[data-behavior~='autofocus']")
          .forEach(input => input.focus())
      })
    })
  }

  close(e) {
    if (e) {
      // Is the clicked element part of the toggle?
      if (
        e.target == this.toggleTarget ||
        $(this.toggleTarget).find(e.target).length
      )
        return
      if (
        e.target.tagName.toLowerCase() == 'input' &&
        $(e.target).closest('.menu__content').length
      )
        return

      this.content &&
        Object.assign(this.content.style, {
          display: 'none'
        })
    } else {
      this.content &&
        Object.assign(this.content.style, {
          display: 'none'
        })
    }

    this.toggleTarget.setAttribute('aria-expanded', false)
    this.cleanup && this.cleanup()

    this.cleanup = undefined

    this.isOpen = false
  }

  keydown(e) {
    if (e.code == 'Escape' && this.isOpen) this.close()
  }
}
