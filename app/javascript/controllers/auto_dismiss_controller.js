import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="auto-dismiss"
// Hides the element after `delay` ms. A delay of 0 (or less) keeps it until `dismiss` is called,
// e.g. from a close button: data-action="auto-dismiss#dismiss".
export default class extends Controller {
    static values = {
        delay: { type: Number, default: 2000 }
    }

    connect() {
        if (this.delayValue <= 0) return

        this.timeout = setTimeout(() => {
            this.dismiss()
        }, this.delayValue)
    }

    disconnect() {
        if (this.timeout) {
            clearTimeout(this.timeout)
        }
    }

    dismiss() {
        this.element.classList.add('hidden')
    }
}
