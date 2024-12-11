import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["editIcon", "viewIcon", "editorDiv", "viewDiv"]

  connect() {
    console.log("Connecting...")
    this.editor = window.simplemde
    this.text = this.editor.value()
    this.mode = "markdown"
    this.timeout = null
    this.editor.codemirror.on("change", this.updateEditor.bind(this))
    // on visibility change fetch the text in case it was updated in another tab
    document.addEventListener("visibilitychange", () => {
      if (document.visibilityState === "visible") {
        this.fetchText()
      }
    })
  }

  get csrfToken() {
    return document.querySelector("meta[name='csrf-token']").content;
  }

  updateEditor() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.saveText()
    }, 1000)
  }

  saveText() {
    const text = this.editor.value()
    if (text === this.text) return;
    const url = this.element.dataset.scratchpadUrl
    fetch(url, {
      method: "PUT",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfToken,
      },
      body: JSON.stringify({ text: text }),
    }).then(response => {
      if (response.ok) {
        return response.json()
      } else {
        console.error("Error saving text:", response)
      }
    }).then(responseBody => {
      this.text = responseBody.text
      this.viewDivTarget.innerHTML = responseBody.html
      console.log("Saved!")
    })
  }

  fetchText() {
    const url = this.element.dataset.scratchpadUrl
    fetch(url).then(response => {
      if (response.ok) {
        return response.json()
      } else {
        console.error("Error fetching text:", response)
      }
    }).then(responseBody => {
      if (this.text === responseBody.text) return;
      this.text = responseBody.text
      this.editor.value(this.text)
      this.viewDivTarget.innerHTML = responseBody.html
    })
  }

  toggleMode() {
    this.mode = this.mode === "markdown" ? "html" : "markdown"
    if (this.mode === "html") {
      this.viewIconTarget.style.display = 'none'
      this.viewDivTarget.style.display = 'block'
      this.editIconTarget.style.display = 'inline-block'
      this.editorDivTarget.style.display = 'none'
    } else {
      this.viewIconTarget.style.display = 'inline-block'
      this.viewDivTarget.style.display = 'none'
      this.editIconTarget.style.display = 'none'
      this.editorDivTarget.style.display = 'block'
    }
  }
}