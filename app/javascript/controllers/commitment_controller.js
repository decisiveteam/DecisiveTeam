import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["joinButton", "joinSection", "statusSection", "nameInput", "participantsList"];

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
    const name = this.nameInputTarget.value.trim();
    fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfToken,
      },
      body: JSON.stringify({
        committed: true,
        name: name,
      }),
    })
      .then(response => response.text())
      .then((html) => {
        this.statusSectionTarget.innerHTML = html;
        this.joinButtonTarget.remove();
        this.nameInputTarget.remove();
        this.joinSectionTarget.innerHTML = "You are committed to participating if critical mass is achieved.";
      })
      .catch((error) => {
        console.error("Error joining commitment:", error);
        this.joinSectionTarget.innerHTML = "Something went wrong. Please refresh the page and try again.";
      });
  }

  showMoreParticipants(event) {
    event.preventDefault();
    if (!this.currentParticipantsListLimit) {
      this.currentParticipantsListLimit = +this.participantsListTarget.dataset.limit;
    }
    const limit = (this.currentParticipantsListLimit += 10);
    const url = `${this.participantsListTarget.dataset.url}?limit=${limit}`;
    fetch(url)
      .then(response => response.text())
      .then((html) => {
        this.participantsListTarget.innerHTML = html;
      })
      .catch((error) => {
        console.error("Error showing more participants:", error);
      });
  }

  async refreshDisplay(event) {
    event.preventDefault()
    if (this.refreshing) return;
    this.refreshing = true;
    this.refreshing = false;
  }

}
