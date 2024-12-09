import { Controller } from "@hotwired/stimulus";
import { formatDistanceToNow } from "date-fns";

export default class extends Controller {
  static values = { datetime: String }

  connect() {
    this.refreshInterval = 60 * 1000;
    if (this.element.textContent === "...") {
      this.updateTime();
    }
    this.startRefreshing();
  }

  disconnect() {
    this.stopRefreshing();
  }

  updateTime() {
    const datetime = new Date(this.datetimeValue);
    const timeagoText = formatDistanceToNow(datetime, { addSuffix: true });
    this.element.innerHTML = `${timeagoText}`;
  }

  startRefreshing() {
    if (this.refreshInterval) {
      this.refreshTimer = setInterval(() => {
        this.updateTime();
      }, this.refreshInterval);
    }
  }

  stopRefreshing() {
    if (this.refreshTimer) {
      clearInterval(this.refreshTimer);
    }
  }
}