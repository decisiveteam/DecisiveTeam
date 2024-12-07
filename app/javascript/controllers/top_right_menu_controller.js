import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["button","menu","plus","plusMenu"]

  connect() {
    this.menuTarget.style.display = 'none'
    document.addEventListener('click', (event) => {
      const isClickInside = this.menuTarget.contains(event.target) || this.buttonTarget.contains(event.target) //||
                            // this.plusMenuTarget.contains(event.target) || this.plusTarget.contains(event.target)
      const isClickOn = event.target === this.buttonTarget || event.target === this.menuTarget //||
                        // event.target === this.plusTarget || event.target === this.plusMenuTarget
      const isMenuVisible = this.menuTarget.style.display === 'block' //|| this.plusMenuTarget.style.display === 'block'
      if (!isClickInside && !isClickOn && isMenuVisible) {
        this.menuTarget.style.display = 'none'
        // this.plusMenuTarget.style.display = 'none'
      }
    })
  }

  toggleMenu() {
    // get the computed x and y position of the button and then set the menu position, right aligned with the button
    const rect = this.buttonTarget.getBoundingClientRect()
    this.menuTarget.style.top = `${rect.bottom}px`
    this.menuTarget.style.right = `${window.innerWidth - rect.right}px`
    this.menuTarget.style.display = this.menuTarget.style.display === 'none' ? 'block' : 'none'
    // this.plusMenuTarget.style.display = 'none'
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