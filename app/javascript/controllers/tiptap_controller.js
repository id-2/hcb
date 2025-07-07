import { Controller } from '@hotwired/stimulus'
import { debounce } from 'lodash/function'
import { Editor } from '@tiptap/core'
import StarterKit from '@tiptap/starter-kit'
import BubbleMenu from '@tiptap/extension-bubble-menu'
import Underline from '@tiptap/extension-underline'
import Placeholder from '@tiptap/extension-placeholder'

export default class extends Controller {
  static targets = ['editor', 'bubbleMenu', 'form', 'contentInput', 'autosaveInput']
  static values = { content: String }

  editor = null

  connect() {   
    const debouncedSubmit = debounce(this.submit.bind(this), 1000, { leading: true })

    this.editor = new Editor({
      element: this.editorTarget,
      extensions: [StarterKit, this.hasBubbleMenuTarget ? BubbleMenu.configure({
        element: this.bubbleMenuTarget,
      }) : null, Underline, Placeholder.configure({
        placeholder: "Write a message to your followers..."
      })],
      editorProps: {
        attributes: {
          class: "outline-none",
        }
      },
      content: this.hasContentValue ? JSON.parse(this.contentValue) : null,
      onUpdate: () => {
        if (this.hasContentValue) {
          debouncedSubmit(true)
        }
      }
    });

    if (this.hasBubbleMenuTarget) {
      this.bubbleMenuTarget.classList.remove("hidden")
    }
  }

  disconnect() {
    this.editor.destroy()
  }

  bold() {
    this.editor.chain().focus().toggleBold().run()
  }

  italic() {
    this.editor.chain().focus().toggleItalic().run()
  }

  underline() {
    this.editor.chain().focus().toggleUnderline().run()
  }

  submit(autosave) {
    this.autosaveInputTarget.value = autosave ? "true" : "false"
    this.contentInputTarget.value = JSON.stringify(this.editor.getJSON());
    this.formTarget.requestSubmit();
  }
}
