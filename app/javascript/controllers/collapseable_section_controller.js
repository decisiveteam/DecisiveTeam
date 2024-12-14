import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["header", "body", "triangleRight", "triangleDown"];

  connect() {
    this.hidden = this.bodyTarget.style.display === "none";
    this.headerTarget.addEventListener("click", this.toggle.bind(this));
    this.headerTarget.style.cursor = "pointer";
    // TODO lazy load URL
  }

  toggle() {
    if (this.hidden) {
      this.show()
    } else {
      this.hide()
    }
  }

  hide() {
    this.bodyTarget.style.display = "none";
    this.triangleRightTarget.style.display = "inline";
    this.triangleDownTarget.style.display = "none";
    this.hidden = true
  }

  show() {
    this.bodyTarget.style.display = "block";
    this.triangleRightTarget.style.display = "none";
    this.triangleDownTarget.style.display = "inline";
    this.hidden = false
  }

}