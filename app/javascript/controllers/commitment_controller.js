import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["joinButton", "statusSection"]

  initialize() {
    document.addEventListener('poll', this.refreshDisplay.bind(this))
  }

  get csrfToken() {
    return document.querySelector("meta[name='csrf-token']").content;
  }

  join(event) {
    event.preventDefault();
    console.log("Joining commitment... " + this.joinButtonTarget.dataset.url);
    this.joinButtonTarget.innerHTML = "Joining...";
    const url = this.joinButtonTarget.dataset.url;
    fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfToken,
      },
    })
      .then(response => response.text())
      .then((html) => {
        this.statusSectionTarget.innerHTML = html;
        this.joinButtonTarget.innerHTML = "You are committed to participating if critical mass is reached.";
      })
      .catch((error) => {
        console.error("Error joining commitment:", error);
        this.joinButtonTarget.innerHTML = "Something went wrong. Please refresh the page and try again.";
      });
  }

  async refreshDisplay(event) {
    event.preventDefault()
    if (this.refreshing) return;
    this.refreshing = true;
    this.refreshing = false;
  }

}
