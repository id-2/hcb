import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['wrapper']
  get inputs () {
    return [...this.wrapperTarget.children];
  }

  initialize () {
    console.log("FOO", this.inputs);

    this.inputs.forEach((input, i) => {
      input.onfocus = (e) => {
        this.handleFocus(i, e);
      }

      input.onpaste = alert

      input.onkeydown = (e) => {
        const { key, ctrlKey, altKey, metaKey } = e;
        if (key == 'Backspace') {
          if (metaKey || altKey || ctrlKey) {
            this.inputs.slice(0, i + 1).forEach(input => {
              input.value = "";
            });
            this.inputs[0].focus();
          } else {
            if (this.inputs[i].value != "") {
              this.inputs[i].value = "";
            } else {
              if (this.inputs[i - 1]) {
                this.inputs[i - 1].value = "";
              }
            }
            if (this.inputs[i - 1]) this.inputs[i - 1].select();
          }
        } else if ("1234567890".includes(key)) {
          this.inputs[i].value = key;
          if (this.inputs[i + 1]) this.inputs[i + 1].select();
        }
        e.preventDefault();
      }
    })
  }

  handleFocus (i, e, select) {
    const n = this.inputValues.length;
    if (i != n) {
      e?.preventDefault?.();
      this.inputs[n][select ? "select" : "focus"]();
    }
  }

  get inputValues () {
    return this.inputs.map(input => input.value).join("");
  }
}
