import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['transaction', 'tagger', 'formField']
  selectedHCBCodes = []

  multiselect(event) {
    const clickedElement = event.currentTarget
    if (event.metaKey || event.ctrlKey) {
      this.toggleHcbCode(clickedElement)
      this.updateTaggerVisbility()
      this.updateFormFieldValue()
    }
  }
  
  toggleHcbCode(clickedElement){
    if (!this.selectedHCBCodes.includes(clickedElement.id)) {
      this.selectedHCBCodes.push(clickedElement.id)
      clickedElement.classList.add('selected__transaction')
    } else {
      this.selectedHCBCodes = this.selectedHCBCodes.filter(
        x => x != clickedElement.id
      )
      clickedElement.classList.remove('selected__transaction')
    }
  }
  
  updateTaggerVisbility() {
    if(this.selectedHCBCodes.length == 0){
      this.taggerTarget.classList.add("display-none")
    } else {
      this.taggerTarget.classList.remove("display-none")
    }
  }

  updateFormFieldValue() {
    this.formFieldTargets.map(formField => {
      formField.value = this.selectedHCBCodes
    })
  }
}
