import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["valueDisplay"];
  static values = { url: String };

  get csrfToken() {
    return document.querySelector("meta[name='csrf-token']").content;
  }

  initialize() {
    document.addEventListener('metricChange', this.refreshMetric.bind(this))
    document.addEventListener('decisionDataUpdated', this.refreshMetric.bind(this))
  }

  async refreshMetric(event) {
    event.preventDefault()
    if (this.refreshing) return;
    this.refreshing = true;
    const response = await fetch(this.urlValue, {
      method: "GET",
      headers: {
        "X-CSRF-Token": this.csrfToken,
      }
    });
    if (response.ok) {
      const json = await response.json();
      this.element.title = json.metric_title;
      this.valueDisplayTarget.textContent = json.metric_value;
      this.refreshing = false;
    } else {
      console.error("Error refreshing metric:", response);
      this.refreshing = false;
    }
  }
}