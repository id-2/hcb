import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
    static targets = ['carousel', 'left', 'right']
    static values = {
        slide: Number,
        length: Number
    }

    connect() {
        this.leftTarget.addEventListener('click', () => {
            this.previous();
        });
        this.rightTarget.addEventListener('click', () => {
            this.next();
        });
    }

    previous () {
        console.log("previous")
        if (this.slideValue <= 0) return this.slideValue = 0;
        this.slideValue--;
        this.setActiveSlide(this.slideValue);
    }

    next () {
        console.log("next")
        if (this.slideValue >= this.lengthValue - 1) return this.slideValue = this.lengthValue - 1;
        this.slideValue++;
        this.setActiveSlide(this.slideValue);
    }

    setActiveSlide (slideNumber) {
        $(this.carouselTarget).find(".carousel__item").removeClass('carousel__item--active');
        $(this.carouselTarget).find(".carousel__item").eq(slideNumber).addClass('carousel__item--active');
        $(this.carouselTarget).closest(".carousel__wrapper").get(0).querySelector(".carousel__number").innerText = slideNumber + 1;
    }

    cache(e) {
        localStorage.setItem(`cached_frame:${this.element.id}`, e.target.innerHTML)
    }
}
