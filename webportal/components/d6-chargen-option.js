import EmberObject, { computed } from '@ember/object';
import { A } from '@ember/array';
import Component from '@ember/component';
import { inject as service } from '@ember/service';

export default Component.extend({
  tagName: '',
  optionDetails: null,
  optionString: null,
  selectOption: false,
  flashMessages: service(),
  gameApi: service(),
  
  didInsertElement: function() {
    this._super(...arguments);
    let self = this;
    this.set('updateCallback', function() { return self.onUpdate(); } );
    this.set('optionString', this.list.mapBy('name')[0]); // initialize value
   },
 
  optionPoints: computed('charList.@each.rating', function() {
    var total = 0;
//    if (this.type != "special ability") {
       total = this.countPointsInGroup(this.get('charList'));
//    } else {
//       list = this.get('charList');
//       list.forEach(function(ability) {
//          let index = this.ranks.indexOf(this.optionRating);
//          ability.cost.forEach(function(level, i) {
//             if (i <= index) {
//                total = total + level; 
//             }
//          });
//       });
//    }
    return total;
  }),

   countPointsInGroup: function(list) {
    if (!list) {
      return 0;
    }
    let total = 0;
    list.forEach(function (ability) {
      total = total + ability.rating;
    });
    return total;
  },

   optionDesc: computed('optionString',function() {
     let list = this.list;
     let item = list.findBy('name', this.optionString);
     if (item) {
       return item.desc;
     } else {
       return null;
    }
   }),

   typePlural: computed('type',function() {
     if (this.type == 'special ability') {
       return 'Special Abilities';
     } else {
       return this.type.capitalize() + "s";
    }
   }),

   typeCapitalize: computed('type',function() {
     if (this.type == 'special ability') {
       return 'Special Ability';
     } else {
         return this.type.capitalize();
    }
   }),

  validateChar: function() {
// lots of stuff to be added here later!
    this.set('charErrors', A());

  },

  actions: {

    abilityChanged() {
      this.validateChar();
    },

    addOption() {
      let option_list = this.list.mapBy('name');
      let optionString = this.optionString || option_list[0];
      let optionDetails = this.optionDetails || null;
      if (!optionString) {
        this.flashMessages.danger("You have to specify a valid " + this.type + ".");
        this.set('selectOption', false);
        return;
      }
      if (this.type == 'special ability') {
         if (!optionDetails) {
           optionDetails = this.optionDesc;
         }
      } else {
         if (!optionDetails) {
            this.flashMessages.danger("You have to specify details for the " + this.type + ".");
            this.set('selectOption', false);
            return;
         }
      }
      this.set('optionDetails', null);
      this.set('selectOption', false);
      this.get('charList').pushObject( EmberObject.create( { name: optionString, rating: 1, details: optionDetails }) );
      this.validateChar();
    }

  }
    
});
