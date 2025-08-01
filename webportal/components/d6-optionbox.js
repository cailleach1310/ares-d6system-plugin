import Component from '@ember/component';
import EmberObject, { computed, action } from '@ember/object';
import { inject as service } from '@ember/service';

export default Component.extend({
  editOption: false,
  optionRating: 0,
  optionDetails: "",
  flashMessages: service(),

    optionDesc: computed('name',function() {
      let list = this.list;
      let item = list.findBy('name', this.name);
      if (item) {
        return item.desc;
      } else {
        return null;
     }
    }),

    optionRanks: computed('name',function() {
      let list = this.list;
      let item = list.findBy('name', this.name);
      if (item) {
        return item.ranks;
      } else {
        return null;
     }
    }),

    @action
    cancelEditOption() {
       this.set('editOption', false);
    },

    @action
    edit() {
       this.set('editOption', true);
       this.set('optionRating', this.rating);
       this.set('optionDetails', this.details);
       this.updated();
    },
    
    @action
    update() {
       this.set('details', this.optionDetails);
       this.set('rating', this.optionRating);
       this.set('editOption', false);
       this.updated();
    },

    @action
    raiseOption() {
       var ranks = this.optionRanks;
       var index = ranks.indexOf(this.optionRating);
       if (index == -1) {
           this.set('optionRating', ranks[0]);
       } else if (index < ranks.length - 1) {
           this.set('optionRating', ranks[index + 1]);
       }
    },

    @action
    lowerOption() {
       var ranks = this.optionRanks;
       var index = ranks.indexOf(this.optionRating);
       if (index > 0) {
           this.set('optionRating', ranks[index - 1]);
        } else {
           this.set('optionRating', 0);
        }
   }
});
