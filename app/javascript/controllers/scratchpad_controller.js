import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["editor"]

  connect() {
    // This is hacky, but it makes it easier since there is only one scratchpad
    // and different parts of the app need to access it, and the behavior is
    // relatively simple.
    window.htScratchpad = this

    // this.visibilityToggleTarget = document.getElementById("scratchpad-visibility-toggle")
    // this.visibilityToggleTarget.addEventListener("click", this.toggleVisibility.bind(this))
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

    document.addEventListener('click', (event) => {
      const isClickInside = this.editorTarget.contains(event.target)
      const isClickOn = event.target === this.editorTarget
      const isEditorVisible = this.editorTarget.style.display === 'block'
      if (!isClickInside && !isClickOn && isEditorVisible) {
        this.editorTarget.style.display = 'none'
      }
    })
  }

  get csrfToken() {
    return document.querySelector("meta[name='csrf-token']").content;
  }

  toggleVisibility() {
    const currentDisplay = this.editorTarget.style.display
    if (currentDisplay === "none" || currentDisplay === "") {
      setTimeout(() => {
        this.editorTarget.style.display = "block"
      }, 1)
    } else {
      setTimeout(() => {
        this.editorTarget.style.display = "none"
      }, 1)
    }
  }

  updateEditor() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.saveText()
    }, 1000)
  }

  setText(text) {
    this.editor.setValue(text)
    this.saveText()
  }

  appendText(text) {
    const url = this.editorTarget.dataset.url + "/append"
    return fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfToken,
      },
      body: JSON.stringify({ text: text }),
    }).then(response => {
      if (response.ok) {
        return response.json()
      } else {
        console.error("Error appending text:", response)
      }
    }).then(responseBody => {
      this.text = responseBody.text
      this.editor.setValue(this.text)
    })
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
        // console.log("Saved!")
      } else {
        console.error("Error saving text:", response)
      }
    })
  }
}