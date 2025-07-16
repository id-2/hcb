import { Node, mergeAttributes } from '@tiptap/core'

export const DonationGoalNode = Node.create({
  name: 'donationGoal',
  group: 'block',
  priority: 2000,
  renderHTML({ HTMLAttributes }) {
    return [
      'div',
      mergeAttributes(HTMLAttributes, {
        class:
          'donationGoal relative card shadow-none border flex flex-col py-2 my-2',
      }),
      [
        'p',
        { class: 'text-center italic' },
        'Your progress towards your goal will display here',
      ],
      [
        'div',
        { class: 'bg-gray-200 dark:bg-neutral-700 rounded-full w-full' },
        [
          'div',
          {
            class:
              'h-full bg-primary rounded w-1/2 flex items-center justify-center',
          },
          ['p', { class: 'text-sm text-black p-[1px] my-0' }, '50%'],
        ],
      ],
    ]
  },
  parseHTML() {
    return [
      {
        tag: 'div',
        getAttrs: node => node.classList.contains('donationGoal') && null,
      },
    ]
  },
  addCommands() {
    return {
      addDonationGoal:
        () =>
        ({ commands }) => {
          return commands.insertContent({ type: this.name })
        },
    }
  },
})