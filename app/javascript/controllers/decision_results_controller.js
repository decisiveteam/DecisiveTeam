import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["message", "age"]
  static values = { url: String }

  get csrfToken() {
    return document.querySelector("meta[name='csrf-token']").content;
  }

  connect() {
    this.initAgeDisplay()
    document.addEventListener('decisionDataUpdated', this.refreshResults.bind(this))
  }

  initAgeDisplay() {
    const timeOfInitialRender = new Date();
    this.ageTarget.textContent = '0 seconds ago';
    this.ageDisplayInterval = setInterval(() => {
      const timeDiff = (new Date()) - timeOfInitialRender;
      const seconds = Math.floor(timeDiff / 1000);
      const minutes = Math.floor(seconds / 60);
      const hours = Math.floor(minutes / 60);
      const days = Math.floor(hours / 24)
      const displayEl = this.ageTarget;
      if (days > 1) {
        displayEl.textContent = days + 'days ago';
      } else if (days == 1) {
        displayEl.textContent = days + ' day ago';
      } else if (hours > 1) {
        displayEl.textContent = hours + ' hours ago';
      } else if (hours == 1) {
        displayEl.textContent = hours + ' hour ago';
      } else if (minutes > 1) {
        displayEl.textContent = minutes + ' minutes ago';
      } else if (minutes == 1) {
        displayEl.textContent = minutes + ' minute ago';
      } else if (seconds == 1) {
        displayEl.textContent = seconds + ' second  ago';
      } else {
        displayEl.textContent = seconds + ' seconds ago';
      }
    }, 1000);
  }

  async refreshResults(event) {
    event.preventDefault()
    if (this.refreshing) return;
    this.refreshing = true;
    clearInterval(this.ageDisplayInterval);
    this.messageTarget.textContent = "Refreshing ...";
    const minTimeout = new Promise(resolve => setTimeout(resolve, 500));
    const response = await fetch(this.urlValue, {
      method: "GET",
      headers: {
        "X-CSRF-Token": this.csrfToken,
      }
    });
    if (response.ok) {
      const html = await response.text();
      await minTimeout;
      this.element.innerHTML = html;
      this.refreshing = false;
    } else {
      this.messageTarget.textContent = "Something went wrong. Refresh the page to get the latest results."
    }
  }
}