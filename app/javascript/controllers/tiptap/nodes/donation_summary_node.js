import { Node, mergeAttributes } from '@tiptap/core'

export const DonationSummaryNode = Node.create({
  name: 'donationSummary',
  group: 'block',
  priority: 2000,
  addAttributes() {
    return {
      startDate: {},
    }
  },
  renderHTML({ HTMLAttributes }) {
    let start
    if (HTMLAttributes.startDate) {
      start = new Date(HTMLAttributes.startDate)
    } else {
      const date = new Date()
      const currentMonth = date.getMonth()
      date.setMonth(currentMonth - 1)
      if (date.getMonth() == currentMonth) date.setDate(0)
      date.setHours(0, 0, 0, 0)

      start = date
    }

    return [
      'div',
      mergeAttributes(HTMLAttributes, {
        class:
          'donationSummary relative card shadow-none border flex flex-col py-2 my-2',
      }),
      [
        'p',
        { class: 'italic text-center' },
        `A donation summary starting on ${start.toDateString()} will appear here.`,
      ],
    ]
  },
  parseHTML() {
    return [
      {
        tag: 'div',
        getAttrs: node => node.classList.contains('donationSummary') && null,
      },
    ]
  },
  addCommands() {
    return {
      addDonationSummary:
        () =>
        ({ commands }) => {
          return commands.insertContent({ type: this.name })
        },
    }
  },
})