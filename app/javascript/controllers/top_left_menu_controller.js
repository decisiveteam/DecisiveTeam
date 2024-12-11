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
    // get the computed x and y position of the button and then set the menu position, left aligned with the button
    const rect = this.buttonTarget.getBoundingClientRect()
    this.menuTarget.style.top = `${rect.bottom}px`
    this.menuTarget.style.left = `${rect.left}px`
    this.menuTarget.style.display = this.menuTarget.style.display === 'none' ? 'block' : 'none'
  }

}