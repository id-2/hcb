import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['shine', 'svg']

  connect() {
    this.handleMouseMove = this.handleMouseMove.bind(this)
    window.addEventListener('mousemove', this.handleMouseMove)
  }

  disconnect() {
    window.removeEventListener('mousemove', this.handleMouseMove)
  }

  handleMouseMove(event) {
    if (!this.hasShineTarget || !this.hasSvgTarget) return

    const { clientX, clientY } = event
    const svgWidth = this.svgTarget.clientWidth / 100

    this.shineTarget.style.top = `${clientY / svgWidth + 6.2}px`
    this.shineTarget.style.left = `${clientX / svgWidth + 9.2}px`
  }
}
