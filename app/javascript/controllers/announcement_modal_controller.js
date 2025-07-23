import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = { blockId: Number }
  static targets = ['input']
  static outlets = ['tiptap']

  submit() {
    const parameters = {}
    for (const target of this.inputTargets) {
      parameters[target.id] = target.value;
    }

    this.tiptapOutlet.donationSummary(parameters, this.blockIdValue);
  }
}
