import { Controller } from '@hotwired/stimulus'
import JSConfetti from 'js-confetti'

const jsConfetti = new JSConfetti()

export default class extends Controller {
  party(event) {
    const emojis = JSON.parse(event.target.dataset.emojis)
    console.log(emojis)
    emojis ? jsConfetti.addConfetti({ emojis }) : jsConfetti.addConfetti()
  }
}
