import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["editor", "visibilityToggle"]

  connect() {
    console.log("Connecting...")
    this.visibilityToggleTarget.addEventListener("click", this.toggleVisibility.bind(this))
    // this.editorTarget.addEventListener("keyup", this.updateEditor.bind(this))
    // this.editorTarget.addEventListener("paste", this.preventPasteBug.bind(this))
    this.text = this.editorTarget.textContent
    this.editor = ace.edit(this.editorTarget, {
      mode: "ace/mode/markdown",
      // theme: "ace/theme/monokai",
      wrap: true,
      showPrintMargin: false,
      tabSize: 2,
      useSoftTabs: true,
      showGutter: false,
      minLines: 10,
      maxLines: 100,
      autoScrollEditorIntoView: true
    });
    this.editor.on("change", this.updateEditor.bind(this))
    console.log("Connected!")
  }

  get csrfToken() {
    return document.querySelector("meta[name='csrf-token']").content;
  }

  toggleVisibility() {
    const currentDisplay = this.editorTarget.style.display
    if (currentDisplay === "none" || currentDisplay === "") {
      this.editorTarget.style.display = "block"
      this.visibilityToggleTarget.textContent = "Hide Scratch Pad"
      this.editor.resize()
    } else {
      this.editorTarget.style.display = "none"
      this.visibilityToggleTarget.textContent = "Show Scratch Pad"
    }
  }

  updateEditor() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.saveText()
    }, 1000)
  }

  saveText() {
    const text = this.editor.getValue()
    if (text === this.text) return;
    const url = this.editorTarget.dataset.url
    fetch(url, {
      method: "PUT",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfToken,
      },
      body: JSON.stringify({ text: text }),
    }).then(response => {
      if (response.ok) {
        this.text = text
        console.log("Saved!")
      } else {
        console.error("Error saving text:", response)
      }
    })
  }
}