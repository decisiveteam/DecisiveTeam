import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["joinButton", "joinButtonMessage", "joinSection", "statusSection",
                    "displayName", "displayNameInput", "editDisplayNameButton",
                    "participantsList"];

  initialize() {
    // document.addEventListener('poll', this.refreshDisplay.bind(this))
  }

  get csrfToken() {
    return document.querySelector("meta[name='csrf-token']").content;
  }

  async editDisplayName(event) {
    event.preventDefault();
    if (this.savingName) return;
    if (this.editingName) {
      const url = this.editDisplayNameButtonTarget.dataset.url;
      const displayName = this.displayNameInputTarget.value;
      // TODO validate display name (cannot be blank)
      this.editDisplayNameButtonTarget.textContent = "Saving...";
      this.savingName = true;
      try {
        const response = await fetch(url, {
          method: "PUT",
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": this.csrfToken,
          },
          body: JSON.stringify({
            name: displayName,
          }),
        });
        const html = await response.text();
        this.joinSectionTarget.innerHTML = html;
        this.savingName = false;
        this.editingName = false;
      } catch (error) {
        console.error("Error saving display name:", error);
      }
    } else {
      this.displayNameTarget.style.display = "none";
      this.displayNameInputTarget.style.display = "inline-block";
      this.editDisplayNameButtonTarget.textContent = "Save";
      this.joinButtonTarget.style.opacity = 0.3;
      this.joinButtonTarget.style.cursor = "not-allowed";
      this.displayNameInputTarget.focus();
      this.editingName = true;
    }
  }

  async updateDisplayName(event) {
    if (event.key === "Enter") {
      return this.editDisplayName(event);
    }
  }

  async join(event) {
    event.preventDefault();
    if (this.editingName) return;
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

  joinButtonMouseEnter(event) {
    if (this.editingName) return;
    this.joinButtonMessageTarget.style.textDecoration = "underline";
  }

  joinButtonMouseLeave(event) {
    this.joinButtonMessageTarget.style.textDecoration = null;
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
