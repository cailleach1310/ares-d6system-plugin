import Component from '@ember/component';
import EmberObject, { computed, action } from '@ember/object';

export default Component.extend({

    minRating: 0,

    combinedRating: computed('rating', 'baseRating', function() {
       let skillDice = this.get('rating');
       let baseDice = this.get('baseRating');
       if ( (skillDice == '0D+0') || (baseDice =='0D+0') ) {
          return '0D+0';
       } else {
          let totalDice = parseInt(skillDice.split("D")[0]) + parseInt(baseDice.split("D")[0]);
          let totalPips = parseInt(skillDice.split("+")[1]) + parseInt(baseDice.split("+")[1]);
          if (totalPips > 2) {
             totalDice = totalDice + 1;
             totalPips = totalPips - 3;
          }
          return totalDice.toString() + "D+" + totalPips.toString();
       }
    }),

    @action
    raiseSkill() {
        var dice = parseInt(this.rating.split("D")[0]);
        var pips = parseInt(this.rating.split("+")[1]);
        if (dice < this.maxDice) {
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
    lowerSkill() {
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
    },

    @action
    learnSkill() {
        this.set('rating', '0D+1');
        this.updated();
    }
});
