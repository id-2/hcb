import { Controller } from '@hotwired/stimulus'
import JSConfetti from 'js-confetti'

const jsConfetti = new JSConfetti()

export default class extends Controller {
  party(event) {
    const emojisRaw = event.target.dataset.emojis
    if (emojisRaw) {
      const emojis = JSON.parse(emojisRaw)
      emojis ? jsConfetti.addConfetti({ emojis }) : jsConfetti.addConfetti()
    } else {
      jsConfetti.addConfetti()
    }
  }
}
