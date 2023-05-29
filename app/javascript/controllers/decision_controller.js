import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "list", "optionsSection", "optionsMessage", "optionsRefresh"];

  optionItem(option) {
    return `<li class="option-item" data-option-id="${option.id}">
      <input type="checkbox" class="approval-button" id="option${option.id}" data-action="click->decision#toggleApprovalValues" ${option.value == 1 ? 'checked' : ''}/>
      <input type="checkbox" class="star-button" id="star-option${option.id}" data-action="click->decision#toggleApprovalValues"/>
      <label for="star-option${option.id}" class="star-button"></label>
      <label for="option${option.id}">${option.title}</label></li>
    `;
  }

  add(event) {
    event.preventDefault();
    const input = this.inputTarget.value.trim();
    if (input.length > 0) {
      this.createOption(input)
        .then((option) => {
          this.listTarget.insertAdjacentHTML("beforeend", this.optionItem(option));
          const countDisplay = document.getElementById('decision-count-display');
          const count = +countDisplay.textContent;
          countDisplay.textContent = '' + (count + 1);
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

  async changeStatus(event) {
    const teamId = this.element.dataset.teamId;
    const decisionId = this.element.dataset.decisionId;
    const status = event.target.value;
    const response = await fetch(`/api/v1/teams/${teamId}/decisions/${decisionId}`, {
      method: "PUT",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfToken,
      },
      body: JSON.stringify({ status }),
    });

    if (!response.ok) {
      throw new Error(`API request failed with status ${response.status}`);
    }

    return response.json();
  }

  async createOption(title) {
    // TODO - refactor this
    const participant_name = new URLSearchParams(window.location.search).get("participant_name");
    const teamId = this.inputTarget.dataset.teamId;
    const decisionId = this.inputTarget.dataset.decisionId;
    const response = await fetch(`/api/v1/teams/${teamId}/decisions/${decisionId}/options`, {
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

    return response.json();
  }

  async toggleApprovalValues(event) {
    // TODO - refactor this
    const participant_name = new URLSearchParams(window.location.search).get("participant_name");
    const teamId = this.inputTarget.dataset.teamId;
    const decisionId = this.inputTarget.dataset.decisionId;
    const optionItem = event.target.parentElement;
    const checkbox = optionItem.querySelector('input.approval-button');
    const optionId = optionItem.dataset.optionId;
    const approved = checkbox.checked;
    const starButton = optionItem.querySelector('input.star-button');
    const stars = starButton.checked;
  
    await fetch(`/api/v1/teams/${teamId}/decisions/${decisionId}/options/${optionId}/approvals`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfToken,
      },
      body: JSON.stringify({ value: approved, stars, participant_name }),
    });
  }

  async refreshOptions(event) {
    event.preventDefault()
    if (this.refreshing) return;
    this.refreshing = true;
    this.optionsMessageTarget.textContent = "Refreshing ...";
    const minTimeout = new Promise(resolve => setTimeout(resolve, 500));
    const url = this.optionsSectionTarget.dataset.url;
    const response = await fetch(url, {
      method: "GET",
      headers: {
        "X-CSRF-Token": this.csrfToken,
      }
    });
    if (response.ok) {
      const html = await response.text();
      await minTimeout;
      this.optionsSectionTarget.outerHTML = html;
      this.refreshing = false;
    } else {
      this.optionsRefreshTarget.textContent = "Something went wrong. Refresh the page to get the latest options."
    }
  }
  
}
