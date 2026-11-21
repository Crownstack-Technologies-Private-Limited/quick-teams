import { Controller } from "@hotwired/stimulus"

// /:account/job_cards (the routes are inside the account scope, like the rest of the app)
function jobCardsPath() {
    const account = document.querySelector("meta[name='current-account']")?.content
    return account ? `/${account}/job_cards` : "/job_cards"
}

// The meta tag is absent where forgery protection is off (the test environment).
function csrfToken() {
    return document.querySelector("meta[name='csrf-token']")?.content || ""
}

export default class extends Controller {
    static values = { date: String }
    static targets = [
        "modalSession", "modalSlot", "modalTitle", "deleteButton",
        "titleInput", "descriptionInput", "slotLengthInput", "cardId", "saveButton", "colorInput"
    ]

    connect() {
        this.editingCard = null
    }

    openModal(event) {
        // Don't allow creating/editing cards for past dates
        const dateValue = this.dateValue;
        const today = new Date().toISOString().split('T')[0];
        if (dateValue < today) {
            return;
        }

        // Check if clicking on a job card for editing
        const jobCard = event.target.closest('.job-card')
        if (jobCard) {
            this.editCard(jobCard)
            return
        }

        // Otherwise, create new card
        const slot = event.currentTarget
        const session = slot.dataset.session
        const slotNumber = slot.dataset.slot

        this.resetModalForNew()
        this.modalSessionTarget.value = session
        this.modalSlotTarget.value = slotNumber

        document.getElementById('jobCardModal').classList.remove('hidden')
    }

    editCard(jobCard) {
        // Don't allow editing cards for past dates
        const dateValue = this.dateValue;
        const today = new Date().toISOString().split('T')[0];
        if (dateValue < today) {
            return;
        }

        const cardId = jobCard.dataset.cardId

        // Fetch card details
        fetch(`${jobCardsPath()}/${cardId}`)
            .then(response => response.json())
            .then(data => {
                this.populateModalForEdit(data)
                document.getElementById('jobCardModal').classList.remove('hidden')
            })
            .catch(error => {
                console.error('Error:', error)
                alert('Error loading card details')
            })
    }

    populateModalForEdit(cardData) {
        this.editingCard = cardData
        this.modalTitleTarget.textContent = 'Edit Job Card'
        this.deleteButtonTarget.classList.remove('hidden')
        this.saveButtonTarget.textContent = 'Update'

        this.titleInputTarget.value = cardData.title
        this.descriptionInputTarget.value = cardData.description || ''
        this.slotLengthInputTarget.value = cardData.slot_length
        this.modalSessionTarget.value = cardData.session
        this.modalSlotTarget.value = cardData.slot_start
        this.cardIdTarget.value = cardData.id
        
        // Set color radio button
        const color = cardData.color || 'gray'
        const colorRadio = this.colorInputTargets.find(input => input.value === color)
        if (colorRadio) {
            colorRadio.checked = true
        }
    }

    resetModalForNew() {
        this.editingCard = null
        this.modalTitleTarget.textContent = 'Add Job Card'
        this.deleteButtonTarget.classList.add('hidden')
        this.saveButtonTarget.textContent = 'Save'

        this.titleInputTarget.value = ''
        this.descriptionInputTarget.value = ''
        this.slotLengthInputTarget.value = '1'
        this.cardIdTarget.value = ''
        
        // Reset color to gray (default)
        const grayRadio = this.colorInputTargets.find(input => input.value === 'gray')
        if (grayRadio) {
            grayRadio.checked = true
        }
    }

    closeModal() {
        document.getElementById('jobCardModal').classList.add('hidden')
        this.resetModalForNew()
    }

    submitForm(event) {
        event.preventDefault()

        const formData = new FormData(event.target)
        const data = Object.fromEntries(formData)
        const cardId = data.card_id

        const isEditing = cardId && cardId !== ''
        const url = isEditing ? `${jobCardsPath()}/${cardId}` : jobCardsPath()
        const method = isEditing ? 'PATCH' : 'POST'

        fetch(url, {
            method: method,
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': csrfToken()
            },
            body: JSON.stringify({ job_card: data })
        })
            .then(response => response.json())
            .then(data => {
                if (data.errors) {
                    alert('Error: ' + data.errors.join(', '))
                } else {
                    this.closeModal()
                    location.reload() // Reload to show changes
                }
            })
            .catch(error => {
                console.error('Error:', error)
                alert('An error occurred')
            })
    }

    deleteCard() {
        const cardId = this.cardIdTarget.value

        if (!cardId || !confirm('Are you sure you want to delete this card?')) {
            return
        }

        fetch(`${jobCardsPath()}/${cardId}`, {
            method: 'DELETE',
            headers: {
                'X-CSRF-Token': csrfToken()
            }
        })
            .then(response => response.json())
            .then(data => {
                if (data.errors) {
                    alert('Error: ' + data.errors.join(', '))
                } else {
                    this.closeModal()
                    location.reload() // Reload to show changes
                }
            })
            .catch(error => {
                console.error('Error:', error)
                alert('An error occurred')
            })
    }
}
