import Component from '@ember/component';

export default Component.extend({
    
    actions: { 
        raise() {
            let rating = this.rating
            if (rating < this.maxRating) {
              rating = rating + 1;
            }
            this.set('rating', rating );
            this.updated();
        },
    
        lower() {
            let rating = this.rating
            if (rating > 0) {
              rating = rating - 1;
            } 
            this.set('rating', rating);
            this.updated();
        }
    }
});
