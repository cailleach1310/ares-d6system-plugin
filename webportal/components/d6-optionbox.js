import Component from '@ember/component';

export default Component.extend({
  editOption: false,
  optionRating: 0,
  optionDetails: "",
    
    actions: { 
        edit() {
            this.set('editOption', true);
            this.set('optionRating', this.rating);
            this.set('optionDetails', this.details);
            this.updated();
        },
    
        update() {
            this.set('details', this.optionDetails);
            this.set('rating', this.optionRating);
            this.set('editOption', false);
            this.updated();
        },

        raise() {
            var index = this.ranks.indexOf(this.optionRating);
            if (index == -1) {
                this.set('optionRating', this.ranks[0]);
            } else if (index < this.ranks.length - 1) {
                this.set('optionRating', this.ranks[index + 1]);
            }
        },

        lower() {
            var index = this.ranks.indexOf(this.optionRating);
            if (index > 0) {
                this.set('optionRating', this.ranks[index - 1]);
            } else {
                this.set('optionRating', 0);
            }
        },

         remove() {
            this.set('rating', 0);
            this.updated();
        }
    }
});
