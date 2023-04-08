import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "list"];

  optionItem(option) {
    return `<span class="option-item" data-id="${option.id}">- <span class="markdown-checkbox">[${option.value == 1 ? 'x' : ' '}]</span> ${option.title}</span>`;
  }

  add(event) {
    event.preventDefault();
    const input = this.inputTarget.value.trim();
    if (input.length > 0) {
      this.createOption(input)
        .then((option) => {
          this.listTarget.insertAdjacentHTML("beforeend", this.optionItem(option));
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
    const decisionId = this.inputTarget.dataset.decisionId;
    const response = await fetch("/dev/decisions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfToken,
      },
      body: JSON.stringify({ title, decision_id: decisionId }),
    });

    if (!response.ok) {
      throw new Error(`API request failed with status ${response.status}`);
    }

    return response.json();
  }

  async toggleApproved(event) {
    const checkbox = event.target;
    const optionItem = checkbox.closest(".option-item");
    const optionId = optionItem.dataset.id;
    const approved = checkbox.textContent == '[x]' ? false : true;
    checkbox.textContent = approved ? '[x]' : '[ ]'
  
    await fetch(`/dev/decisions`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfToken,
      },
      body: JSON.stringify({ option_id: optionId, value: approved }),
    });
  }
  
}
