import { Application } from "@hotwired/stimulus"
import ScrollTo from 'stimulus-scroll-to'

//import { registerControllers } from 'stimulus-vite-helpers'
import StimulusControllerResolver, { createViteGlobResolver } from 'stimulus-controller-resolver'
import consumer from '../channels/consumer'
const application = Application.start()
application.register('scroll-to', ScrollTo)
application.consumer = consumer

//const controllers = import.meta.globEager('./**/*_controller.js')
//registerControllers(application, controllers)

StimulusControllerResolver.install(application, createViteGlobResolver(
  import.meta.glob('../controllers/**/*_controller.js')
))



