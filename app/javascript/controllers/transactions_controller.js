import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
	static targets = ["transaction", "tagger"];
	selectedElements = [];

	trackClick(event) {
		const clickedElement = event.currentTarget;
		if (event.metaKey || event.ctrlKey) {
			if(!this.selectedElements.includes(clickedElement.id)){
				this.selectedElements.push(clickedElement.id);
				clickedElement.classList.add("selected__transaction")
				if(this.selectedElements.length > 0){
					this.taggerTarget.classList.remove("display-none")
				}
			}
			else{
				this.selectedElements = this.selectedElements.filter(x => x != clickedElement.id);
				clickedElement.classList.remove("selected__transaction")
				if(this.selectedElements.length == 0){
					this.taggerTarget.classList.add("display-none")
				}
			}
		}
	}
}
