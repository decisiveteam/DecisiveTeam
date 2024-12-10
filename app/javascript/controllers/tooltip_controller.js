import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["info"];

  connect() {
    this.element.addEventListener("mouseenter", this.show.bind(this));
    this.element.addEventListener("mouseleave", this.hide.bind(this));
    this.infoTarget.addEventListener("mouseenter", this.preventHide.bind(this));
    this.infoTarget.addEventListener("mouseleave", this.allowHide.bind(this));

    // if mobile
    if (window.innerWidth < 768) {
      this.connectMobile();
    }
  }

  connectMobile() {
    // for mobile, we want to show the tooltip on click
    this.element.addEventListener("click", this.toggle.bind(this));
    // prevent the tooltip from hiding when clicking on it
    this.infoTarget.addEventListener("click", (event) => {
      event.stopPropagation();
    });
    // hide on click outside
    document.addEventListener("click", (event) => {
      if (this.showing && !this.element.contains(event.target)) {
        this.hideImmediately();
      }
    });
  }

  show() {
    this.infoTarget.style.display = "block";
    // reposition the tooltip
    const rect = this.element.getBoundingClientRect();
    const infoRect = this.infoTarget.getBoundingClientRect();
    const top = rect.top - infoRect.height - 10;
    const left = Math.max(
      15,
      rect.left + rect.width / 2 - infoRect.width / 2
    )
    this.infoTarget.style.top = `${top}px`;
    this.infoTarget.style.left = `${left}px`;
    this.showing = true;
  }

  hide() {
    clearTimeout(this.hideTimeout);
    this.hideTimeout = setTimeout(() => {
      if (this.allowHide) {
        this.infoTarget.style.display = "none";
        this.showing = false;
      }
    }, 300);
  }

  hideImmediately() {
    clearTimeout(this.hideTimeout);
    this.infoTarget.style.display = "none";
    this.showing = false;
  }

  preventHide() {
    this.allowHide = false;
  }

  allowHide() {
    this.allowHide = true;
  }

  toggle() {
    if (this.showing) {
      this.hideImmediately();
    } else {
      this.show();
    }
  }

}
