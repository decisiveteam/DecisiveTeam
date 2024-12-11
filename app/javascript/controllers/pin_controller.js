import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["pinButton"]

  connect() {
    this.pinButtonTarget.addEventListener("click", this.togglePin.bind(this))
    this.isPinned = this.pinButtonTarget.dataset.isPinned == 'true'
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