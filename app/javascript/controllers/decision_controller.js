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

  toggleResults(event) {
    event.preventDefault();
    const text = event.target.textContent;
    const table = document.getElementById('results');
    if (text == 'Show results') {
      table.style.display = 'inline';
      event.target.textContent = 'Hide results';
    } else if (text == 'Hide results') {
      table.style.display = 'none';
      event.target.textContent = 'Show results';
    } else {
      throw new Error(`Unexpected text value "${text}"`);
    }
  }
  
}
