import { Controller } from '@hotwired/stimulus'
import { Editor } from '@tiptap/core'
import StarterKit from '@tiptap/starter-kit'
import BubbleMenu from '@tiptap/extension-bubble-menu'
import Underline from '@tiptap/extension-underline'
import Placeholder from '@tiptap/extension-placeholder'

export default class extends Controller {
  static targets = ['editor', 'bubbleMenu', 'form', 'contentInput']

  editor = null

  connect() {
    this.editor = new Editor({
      element: this.editorTarget,
      extensions: [StarterKit.configure({
        paragraph: {
          HTMLAttributes: {
            class: "my-0"
          }
        }
      }), BubbleMenu.configure({
        element: this.bubbleMenuTarget,
      }), Underline, Placeholder.configure({
        placeholder: "Write a message to your followers..."
      })],
      editorProps: {
        attributes: {
          class: "outline-none",
        }
      }
    });
    this.bubbleMenuTarget.classList.remove("hidden")
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

  submit() {
    this.contentInputTarget.value = JSON.stringify(this.editor.getJSON());
    this.form.requestSubmit();
  }
}
