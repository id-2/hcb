import { Controller } from '@hotwired/stimulus'
import { minimalSetup, EditorView } from 'codemirror'
import { css } from '@codemirror/lang-css'
import { dracula } from 'thememirror'
export default class extends Controller {
  static targets = ['editor', 'input']
  static values = {
    doc: String
  }
  connect() {
    this.editor = new EditorView({
      doc: this.docValue,
      parent: this.editorTarget,
      extensions: [
        minimalSetup,
        css(),
        EditorView.updateListener.of(view => {
          if (view.docChanged) {
            this.sync()
          }
        }),
        dracula
      ]
    })
  }
  disconnect() {
    this.editor.destroy()
  }
  sync() {
    this.inputTarget.value = this.editor.state.doc.toString()
  }
}
