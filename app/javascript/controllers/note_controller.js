import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["confirmButton", "confirmButtonMessage", "confirmSection",
                    "displayName", "displayNameInput", "editDisplayNameButton",
                    "historyLog"];

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
        this.confirmSectionTarget.innerHTML = html;
        this.savingName = false;
        this.editingName = false;
      } catch (error) {
        console.error("Error saving display name:", error);
      }
    } else {
      this.displayNameTarget.style.display = "none";
      this.displayNameInputTarget.style.display = "inline-block";
      this.editDisplayNameButtonTarget.textContent = "Save";
      this.confirmButtonTarget.style.opacity = 0.3;
      this.confirmButtonTarget.style.cursor = "not-allowed";
      this.displayNameInputTarget.focus();
      this.editingName = true;
    }
  }

  async updateDisplayName(event) {
    if (event.key === "Enter") {
      return this.editDisplayName(event);
    }
  }

  async confirm(event) {
    event.preventDefault();
    if (this.editingName) return;
    console.log("Confirming read... " + this.confirmButtonTarget.dataset.url);
    this.confirmButtonTarget.innerHTML = "Confirming...";
    const url = this.confirmButtonTarget.dataset.url;
    try {
      const response = await fetch(url, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": this.csrfToken,
        },
        body: JSON.stringify({
          confirmed: true,
        }),
      });
      const html = await response.text();
      this.confirmButtonTarget.remove();
      this.confirmSectionTarget.innerHTML = html;
      this.refreshHistoryLog(event);
    } catch (error) {
      console.error("Error confirming read:", error);
      this.confirmSectionTarget.innerHTML = "Something went wrong. Please refresh the page and try again.";
    }
  }

  confirmButtonMouseEnter(event) {
    if (this.editingName) return;
    this.confirmButtonMessageTarget.style.textDecoration = "underline";
  }

  confirmButtonMouseLeave(event) {
    this.confirmButtonMessageTarget.style.textDecoration = null;
  }

  async refreshHistoryLog(event) {
    event.preventDefault();
    const url = this.historyLogTarget.dataset.url;
    try {
      const response = await fetch(url);
      const html = await response.text();
      this.historyLogTarget.innerHTML = html;
    } catch (error) {
      console.error("Error showing more history:", error);
    }
  }

  async refreshDisplay(event) {
    event.preventDefault()
    if (this.refreshing) return;
    this.refreshing = true;
    this.refreshing = false;
  }

}
