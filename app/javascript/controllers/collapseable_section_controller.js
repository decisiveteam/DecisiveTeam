import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["header", "body", "triangleRight", "triangleDown", "lazyLoad"];

  connect() {
    this.hidden = this.bodyTarget.style.display === "none";
    this.headerTarget.addEventListener("click", this.toggle.bind(this));
    this.headerTarget.style.cursor = "pointer";
    this.lazyLoadCompleted = !this.lazyLoadTarget.dataset.url;
    if (!this.hidden) {
      this.show()
    }
  }

  get csrfToken() {
    return document.querySelector("meta[name='csrf-token']").content;
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
    if (this.lazyLoadCompleted !== true) {
      this.showLoading()
      fetch(this.lazyLoadTarget.dataset.url, {
        method: "GET",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": this.csrfToken,
        }
      }).then(response => response.text())
        .then(html => {
          // NOTE this removes this.lazyLoadTarget from the DOM
          // but that's fine because we don't need it anymore.
          this.bodyTarget.innerHTML = html
          this.lazyLoadCompleted = true
        })
    }
    this.bodyTarget.style.display = "block";
    this.triangleRightTarget.style.display = "none";
    this.triangleDownTarget.style.display = "inline";
    this.hidden = false
  }

  showLoading() {
    // TODO: show a spinner
    this.lazyLoadTarget.innerHTML = "<ul><li>...</li></ul>"
  }

}