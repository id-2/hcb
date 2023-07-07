import { Controller } from '@hotwired/stimulus'

function unselect () {
    if (document.selection ? (document.selection?.empty?.(), true) : false) return;

    if (window.getSelection) {
        window.getSelection()?.removeAllRanges();
    }

    let activeElement = document.activeElement;
    let tagName = activeElement?.nodeName?.toLowerCase?.();

    if (!activeElement || !(tagName == "textarea" || (tagName == "input" && activeElement.type == "text"))) return;
    
    activeElement.selectionStart = activeElement.selectionEnd;
}

export default class extends Controller {
  static targets = ['canonicalTransaction', 'canonicalPendingTransaction', 'memoColumn', 'memoText']

  initialize() {
    this.#addEventListeners();
  }

  #memoDoubleClick (event) {
    console.log("memoDoubleClick");

    if (this.memoTextTarget.disabled) {
      event.preventDefault();
      unselect();

      document.querySelectorAll(`[data-rename-target="memoText"]`).forEach(element => {
        element.disabled = true;
      });

      this.memoTextTarget.disabled = false;

      this.memoTextTarget.focus();
      this.memoTextTarget.select();

      let eventListener = this.memoTextTarget.addEventListener('blur', blurEvent => {
        this.memoTextTarget.disabled = true;
        this.memoTextTarget.removeEventListener('blur', eventListener);
      });
    } else {

    }

    this.memoTextTarget.focus();
  }

  #memoClick (event) {
    console.log("memoClick");

    this.memoTextTarget.focus();
  }

  #addEventListeners () {
    this.memoColumnTarget.addEventListener('dblclick', this.#memoDoubleClick.bind(this));
    this.memoColumnTarget.addEventListener('click', this.#memoClick.bind(this));
  }

  #saveMemo () {
    this.canonicalTransactionTarget.classList.add('transaction__memo--loading');
  }

}
