import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "list", "optionsSection"];

  initialize() {
    document.addEventListener('poll', this.refreshOptions.bind(this))
  }

  add(event) {
    event.preventDefault();
    const input = this.inputTarget.value.trim();
    if (input.length > 0) {
      this.createOption(input)
        .then(response => response.text())
        .then((html) => {
          this.listTarget.innerHTML = html;
          this.inputTarget.value = "";
        })
        .catch((error) => {
          console.error("Error creating option:", error);
        });
    }
  }

  get csrfToken() {
    return document.querySelector("meta[name='csrf-token']").content;
  }

  get decisionIsClosed() {
    if (!this.optionsSectionTarget.dataset.deadline) return false;
    try {
      const deadlineDate = new Date(this.optionsSectionTarget.dataset.deadline);
      const now = new Date();
      return now > deadlineDate;
    } catch (error) {
      console.error("Error determining if decision is closed:", error);
      return false;
    }
  }

  async createOption(title) {
    const url = this.optionsSectionTarget.dataset.url;
    const response = await fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfToken,
      },
      body: JSON.stringify({ title }),
    });

    if (!response.ok) {
      throw new Error(`API request failed with status ${response.status}`);
    }
    const ddu = new Event('decisionDataUpdated');
    document.dispatchEvent(ddu);
    return response;
  }

  nextApprovalState(approved, stars) {
    if (stars) {
      return [false, false]
    } else if (approved) {
      return [true, true]
    } else {
      return [true, false]
    }
  }

  async toggleApprovalValues(event) {
    const decisionId = this.inputTarget.dataset.decisionId;
    const optionItem = event.target.parentElement;
    const checkbox = optionItem.querySelector('input.approval-button');
    const starButton = optionItem.querySelector('input.star-button');

    const optionId = optionItem.dataset.optionId;
    let approved = checkbox.checked;
    let stars = starButton.checked;

    if (event.target.id.startsWith('option-label')) {
      // Cycle approval state
      [approved, stars] = this.nextApprovalState(approved, stars);
      checkbox.checked = approved;
      starButton.checked = stars;
    }
  
    this.updatingApprovals = true;
    await fetch(`/api/v1/decisions/${decisionId}/options/${optionId}/approvals`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfToken,
      },
      body: JSON.stringify({ value: approved, stars }),
    });
    this.updatingApprovals = false;
    this.lastApprovalUpdate = new Date().toString();
    const ddu = new Event('decisionDataUpdated');
    document.dispatchEvent(ddu);
  }

  async cycleApprovalState(event) {
    event.preventDefault();
    return this.toggleApprovalValues(event);
  }

  async refreshOptions(event) {
    event.preventDefault()
    if (this.refreshing || this.updatingApprovals) return;
    this.refreshing = true;
    const url = this.optionsSectionTarget.dataset.url;
    const lastApprovalUpdateBeforeRefresh = this.lastApprovalUpdate;
    const response = await fetch(url, {
      method: "GET",
      headers: {
        "X-CSRF-Token": this.csrfToken,
      }
    });
    const refreshIsStale = this.updatingApprovals || (this.lastApprovalUpdate !== lastApprovalUpdateBeforeRefresh);
    if (refreshIsStale) {
      this.refreshing = false;
    } else if (response.ok) {
      const html = await response.text();
      if (html !== this.previousOptionsListHtml) {
        this.listTarget.innerHTML = html;
        this.previousOptionsListHtml = html;
      } else if (this.decisionIsClosed) {
        this.hideOptions();
      }
      this.refreshing = false;
    } else {
      console.error("Error refreshing options:", response);
      this.refreshing = false;
    }
  }

  hideOptions() {
    this.optionsSectionTarget.style.display = 'none';
  }
  
}
