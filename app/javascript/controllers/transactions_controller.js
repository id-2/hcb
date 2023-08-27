import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
	static targets = ["transaction", "tagger", "formField"];
	selectedHCBCodes = [];

	trackClick(event) {
		const clickedElement = event.currentTarget;
		if (event.metaKey || event.ctrlKey) {
			if(!this.selectedHCBCodes.includes(clickedElement.id)){
				this.selectedHCBCodes.push(clickedElement.id);
				clickedElement.classList.add("selected__transaction")
				if(this.selectedHCBCodes.length > 0){
					this.taggerTarget.classList.remove("display-none")
				}
			}
			else{
				this.selectedHCBCodes = this.selectedHCBCodes.filter(x => x != clickedElement.id);
				clickedElement.classList.remove("selected__transaction")
				if(this.selectedHCBCodes.length == 0){
					this.taggerTarget.classList.add("display-none")
				}
			}
			this.updateFormFieldValue()
		}
	}
	
	updateFormFieldValue() {
		this.formFieldTargets.map(formField => {
			formField.value = this.selectedHCBCodes;
		})
	}
}
