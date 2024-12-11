// Overwrite the clipboard controller for more control over success message display
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "source", "successMessage"]

  copy(event) {
    event.preventDefault()

    const text = this.sourceTarget.value

    navigator.clipboard.writeText(text).then(() => this.copied())
  }

  copied() {

    if (this.timeout) {
      clearTimeout(this.timeout)
    }

    this.buttonTarget.style.display = 'none'
    this.successMessageTarget.style.display = 'inline'

    this.timeout = setTimeout(() => {
      this.buttonTarget.style.display = 'inline'
      this.successMessageTarget.style.display = 'none'
    }, 2000)
  }
}
