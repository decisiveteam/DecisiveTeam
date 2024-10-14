import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["joinButton", "joinSection", "statusSection", "nameInput", "participantsList"];

  initialize() {
    // document.addEventListener('poll', this.refreshDisplay.bind(this))
  }

  get csrfToken() {
    return document.querySelector("meta[name='csrf-token']").content;
  }

  async join(event) {
    event.preventDefault();
    console.log("Joining commitment... " + this.joinButtonTarget.dataset.url);
    this.joinButtonTarget.innerHTML = "Joining...";
    const url = this.joinButtonTarget.dataset.url;
    try {
      const response = await fetch(url, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": this.csrfToken,
        },
        body: JSON.stringify({
          committed: true,
        }),
      });
      const html = await response.text();
      this.joinButtonTarget.remove();
      this.joinSectionTarget.innerHTML = html;
      this.refreshStatusSection(event);
      this.refreshParticipantsList(event);
    } catch (error) {
      console.error("Error joining commitment:", error);
      this.joinSectionTarget.innerHTML = "Something went wrong. Please refresh the page and try again.";
    }
  }

  async refreshStatusSection(event) {
    event.preventDefault();
    const url = this.statusSectionTarget.dataset.url;
    try {
      const response = await fetch(url);
      const html = await response.text();
      this.statusSectionTarget.innerHTML = html;
    } catch (error) {
      console.error("Error refreshing status:", error);
    }
  }

  async refreshParticipantsList(event) {
    event.preventDefault();
    if (!this.currentParticipantsListLimit) {
      this.currentParticipantsListLimit = +this.participantsListTarget.dataset.limit;
    }
    const limit = this.currentParticipantsListLimit;
    const url = `${this.participantsListTarget.dataset.url}?limit=${limit}`;
    try {
      const response = await fetch(url);
      const html = await response.text();
      this.participantsListTarget.innerHTML = html;
    } catch (error) {
      console.error("Error showing more participants:", error);
    }
  }

  async showMoreParticipants(event) {
    if (!this.currentParticipantsListLimit) {
      this.currentParticipantsListLimit = +this.participantsListTarget.dataset.limit;
    }
    this.currentParticipantsListLimit += 10
    return this.refreshParticipantsList(event);
  }

  async refreshDisplay(event) {
    event.preventDefault()
    if (this.refreshing) return;
    this.refreshing = true;
    this.refreshing = false;
  }

}
