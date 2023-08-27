import { Controller } from "@hotwired/stimulus";

let lastInitialized = null;

export default class extends Controller {
  static targets = []
  static values = { url: String }

  get csrfToken() {
    return document.querySelector("meta[name='csrf-token']").content;
  }

  initialize() {
    // TODO Only poll if the decision is open
    document.addEventListener('decisionDataUpdated', this.refreshResults.bind(this))
    document.addEventListener('poll', this.refreshResults.bind(this))
    // TODO figure out how to prevent multiple instances of this controller
    lastInitialized = this;
  }

  async refreshResults(event) {
    event.preventDefault()
    if (this.refreshing || lastInitialized != this) return;
    this.refreshing = true;
    const response = await fetch(this.urlValue, {
      method: "GET",
      headers: {
        "X-CSRF-Token": this.csrfToken,
      }
    });
    if (response.ok) {
      const html = await response.text();
      this.element.innerHTML = html;
      this.refreshing = false;
    } else {
      console.error("Error refreshing results:", response);
      this.refreshing = false;
    }
  }
}