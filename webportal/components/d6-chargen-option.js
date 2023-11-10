import EmberObject, { computed } from '@ember/object';
import { A } from '@ember/array';
import Component from '@ember/component';
import { inject as service } from '@ember/service';
import { capitalize } from '@ember/string'; // ember 4

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
    this.set('optionString', this.opList.mapBy('name')[0]); // initialize value
   },
 
  optionPoints: computed('charList.@each.rating', function() {
    var total = 0;
    if (this.type != "special ability") {
       total = this.countPointsInGroup(this.get('charList'));
    } else {
       total = this.countSpecialAbilityPoints(this.get('charList'),this.get('opList'),this.get('specDifficulty'));
    }
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

   countSpecialAbilityPoints: function(cList,sList,diff) {
     if (!cList) {
       return 0;
     }
     let total = 0;
     let first = 0;
     let factor = 0;
     cList.forEach(function(opt) {
        if (opt.rating > 0) {
           let item = sList.findBy('name', opt.name);
           first = item.cost;
        // determine cost factor for ranks > 1
           if (diff != "cost") {
              factor = diff;  // usually 1, but keeping it configurable
           } else {
              factor = first;
           }
           total = total + first + ((opt.rating - 1) * factor);
         }
       });
       return total;
   },

   optionDesc: computed('optionString',function() {
     let list = this.opList;
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
       return capitalize(this.type) + "s"; // ember 4
     // return this.type.capitalize() + "s"; // ember < 4
    }
   }),

   typeCapitalize: computed('type',function() {
     if (this.type == 'special ability') {
       return 'Special Ability';
     } else {
         return capitalize(this.type); // ember 4
     // return this.type.capitalize() + "s"; // ember < 4
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
      let option_list = this.opList.mapBy('name');
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
