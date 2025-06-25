import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['badge', 'container']

  connect() {
    this.updateBadge()
  }

  async updateBadge() {
    try {
      const blogUrl = window.location.hostname === "hcb.hackclub.com" ? 'https://blog.hcb.hackclub.com' : "http://localhost:3001"

      const { count, featuredPosts } = await fetch(
        `${blogUrl}/api/unreads`,
        {
          credentials: 'include',
        }
      ).then(res => res.json())

      if (count < 1) return

      this.badgeTarget.innerText = count
      this.badgeTarget.classList.remove('hidden')

      if (featuredPosts.length > 0) {
        this.containerTarget.src = `/changelog?${featuredPosts.map(p => `urls[]=${encodeURIComponent(`${blogUrl}/embed/${p}`)}`).join("&")}`
      }
    } catch (error) {
      console.error('Error fetching unreads', error)
    }
  }
}
