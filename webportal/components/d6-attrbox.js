import Component from '@ember/component';
import EmberObject, { computed, action } from '@ember/object';
import { A } from '@ember/array';

export default Component.extend({
    minRating: computed('name', function() {
       if (this.extranormAttrs.includes(this.get('name'))) {
          return 0;
       } else {
          return 1;
       }
    }),
    
    @action
    raiseAttr() {
       var dice = parseInt(this.rating.split("D")[0]);
       var pips = parseInt(this.rating.split("+")[1]);
       if (dice < this.maxRating) {
          if (pips == 2) {
            dice = dice + 1;
            pips = 0;
          } else {
             if (pips < 2) {
                pips = pips + 1;
             }
          }
       }
       this.set('rating', dice.toString() + "D+" + pips.toString() );
       this.updated();
   },
    
   @action
   lowerAttr() {
       var dice = parseInt(this.rating.split("D")[0]);
       var pips = parseInt(this.rating.split("+")[1]);
       if ((pips == 0) && (dice > this.minRating)) {
         dice = dice - 1;
         pips = 2;
       } else {
          if (pips > 0) {
             pips = pips - 1;
          }
       }
       this.set('rating', dice.toString() + "D+" + pips.toString() );
       this.updated();
   }
});
