import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "list", "optionsSection", "optionsMessage", "optionsRefresh"];

  optionItem(option) {
    return `<span class="option-item" data-option-id="${option.id}">- <span class="markdown-checkbox" data-action="click->decision#toggleApproved">[${option.value == 1 ? 'x' : ' '}]</span> ${option.title}</span>\n`;
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

  async createOption(title) {
    const teamId = this.inputTarget.dataset.teamId;
    const decisionId = this.inputTarget.dataset.decisionId;
    const response = await fetch(`/api/v1/teams/${teamId}/decisions/${decisionId}/options`, {
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

    return response.json();
  }

  async toggleApproved(event) {
    const teamId = this.inputTarget.dataset.teamId;
    const decisionId = this.inputTarget.dataset.decisionId;
    const checkbox = event.target;
    const optionItem = checkbox.closest(".option-item");
    const optionId = optionItem.dataset.optionId;
    const approved = checkbox.textContent == '[x]' ? false : true;
    checkbox.textContent = approved ? '[x]' : '[ ]'
  
    await fetch(`/api/v1/teams/${teamId}/decisions/${decisionId}/options/${optionId}/approvals`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfToken,
      },
      body: JSON.stringify({ value: approved }),
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
