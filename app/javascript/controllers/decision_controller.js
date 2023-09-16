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

  async createOption(title) {
    // TODO - refactor this
    const participant_name = new URLSearchParams(window.location.search).get("participant_name");
    // const decisionId = this.inputTarget.dataset.decisionId;
    const url = this.optionsSectionTarget.dataset.url;
    const response = await fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfToken,
      },
      body: JSON.stringify({ title, participant_name }),
    });

    if (!response.ok) {
      throw new Error(`API request failed with status ${response.status}`);
    }
    const ddu = new Event('decisionDataUpdated');
    document.dispatchEvent(ddu);
    return response;
  }

  async toggleApprovalValues(event) {
    // TODO - refactor this
    const participant_name = new URLSearchParams(window.location.search).get("participant_name");
    const decisionId = this.inputTarget.dataset.decisionId;
    const optionItem = event.target.parentElement;
    const checkbox = optionItem.querySelector('input.approval-button');
    const optionId = optionItem.dataset.optionId;
    const approved = checkbox.checked;
    const starButton = optionItem.querySelector('input.star-button');
    const stars = starButton.checked;
  
    this.updatingApprovals = true;
    await fetch(`/api/v1/decisions/${decisionId}/options/${optionId}/approvals`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfToken,
      },
      body: JSON.stringify({ value: approved, stars, participant_name }),
    });
    this.updatingApprovals = false;
    this.lastApprovalUpdate = new Date().toString();
    const ddu = new Event('decisionDataUpdated');
    document.dispatchEvent(ddu);
  }

  async refreshOptions(event) {
    event.preventDefault()
    if (this.refreshing || this.updatingApprovals) return;
    this.refreshing = true;
    const url = this.optionsSectionTarget.dataset.url;
    const participant_name = new URLSearchParams(window.location.search).get("participant_name");
    if (participant_name) url += `?participant_name=${participant_name}`;
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
      }
      this.refreshing = false;
    } else {
      console.error("Error refreshing options:", response);
      this.refreshing = false;
    }
  }
  
}
