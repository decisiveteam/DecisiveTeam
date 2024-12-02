import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["button","menu"]

  connect() {
    this.menuTarget.style.display = 'none'
    document.addEventListener('click', (event) => {
      const isClickInside = this.menuTarget.contains(event.target) || this.buttonTarget.contains(event.target)
      const isClickOn = event.target === this.buttonTarget || event.target === this.menuTarget
      const isMenuVisible = this.menuTarget.style.display === 'block'
      if (!isClickInside && !isClickOn && isMenuVisible) {
        this.menuTarget.style.display = 'none'
      }
    })
  }

  toggleMenu() {
    // get the computed x and y position of the button and then set the menu position, right aligned with the button
    const rect = this.buttonTarget.getBoundingClientRect()
    this.menuTarget.style.top = `${rect.bottom}px`
    this.menuTarget.style.right = `${window.innerWidth - rect.right}px`
    this.menuTarget.style.display = this.menuTarget.style.display === 'none' ? 'block' : 'none'
  }

  toggleScratchpad() {
    window.htScratchpad.toggleVisibility()
    this.toggleMenu()
  }

  get csrfToken() {
    return document.querySelector("meta[name='csrf-token']").content;
  }

  togglePin() {
    const url = this.pinButtonTarget.dataset.pinUrl
    fetch(url, {
      method: "PUT",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfToken,
      },
      body: JSON.stringify({
        pinned: !this.isPinned,
      }),
    }).then(response => {
      if (response.ok) return response.json()
      throw new Error("Network response was not ok.")
    }).then(responseBody => {
      this.isPinned = responseBody.pinned
      this.pinButtonTarget.style.opacity = this.isPinned ? '1' : '0.2'
      this.pinButtonTarget.title = responseBody.click_title
    })
  }
}