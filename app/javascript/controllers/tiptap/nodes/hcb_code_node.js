import { Node, mergeAttributes } from '@tiptap/core'

export const HcbCodeNode = Node.create({
  name: 'hcbCode',
  group: 'block',
  priority: 2000,
  addAttributes() {
    return {
      code: {},
    }
  },
  renderHTML({ HTMLAttributes }) {
    return [
      'div',
      mergeAttributes(HTMLAttributes, {
        class:
          'hcbCode relative card shadow-none border flex flex-col py-2 my-2',
      }),
      [
        'p',
        { class: 'italic text-center' },
        `Your transaction (${HTMLAttributes.code}) will appear here.`,
      ],
    ]
  },
  parseHTML() {
    return [
      {
        tag: 'div',
        getAttrs: node => node.classList.contains('hcbCode') && null,
      },
    ]
  },
  addCommands() {
    return {
      addHcbCode:
        code =>
        ({ commands }) => {
          return commands.insertContent({
            type: this.name,
            attrs: { code },
          })
        },
    }
  },
})