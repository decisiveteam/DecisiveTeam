import { Application } from "@hotwired/stimulus"
import Timeago from 'stimulus-timeago'
import Dropdown from 'stimulus-dropdown'

const application = Application.start()
application.register('timeago', Timeago)
application.register('dropdown', Dropdown)

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }
