// Load all the controllers within this directory and all subdirectories.
// Controller files must be named *_controller.js.

import { Application } from '@hotwired/stimulus'
import { definitionsFromContext } from '@hotwired/stimulus-webpack-helpers'
import { installErrorHandler } from '@appsignal/stimulus'
import appsignal from '../appsignal'
import airbrake from '../airbrake'

const application = Application.start()

if (appsignal) {
  installErrorHandler(appsignal, application)
}

if (airbrake) {
  application.handleError = error => {
    airbrake.notify(error)
  }
}

const context = require.context('.', true, /_controller\.js$/)
application.load(definitionsFromContext(context))
