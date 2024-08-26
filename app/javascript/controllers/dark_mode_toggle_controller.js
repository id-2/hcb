import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['toggle']
  connect() {
    const targets = this.toggleTargets;

    for(const target of targets) {
      const check = target.querySelector(".hidden");
      const isDark = getCookie('theme')
      const value = target.getAttribute('data-value');
      if (isDark === value) {
        check.classList.remove('hidden');
      }
    }
  }

  cache(e) {
  }
}
