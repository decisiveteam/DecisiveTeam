import { Application } from "@hotwired/stimulus"
import Timeago from 'stimulus-timeago'
// import Clipboard from 'stimulus-clipboard'

const application = Application.start()
application.register('timeago', Timeago)
// application.register('clipboard', Clipboard)

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }
