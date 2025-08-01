import EmberObject, { computed, action } from '@ember/object';
import { A } from '@ember/array';
import Component from '@ember/component';
import { inject as service } from '@ember/service';
import { capitalize } from '@ember/string'; // ember 4
import { pushObject } from 'ares-webportal/helpers/object-ext';

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
    let optionList = A(this.opList);
    this.set('optionString', optionList.mapBy('name')[0]); // initialize value
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
     let theList = A(sList);
     cList.forEach(function(opt) {
        if (opt.rating > 0) {
           let item = theList.findBy('name', opt.name);
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
     let list = A(this.opList);
     let item = list.findBy('name', this.optionString);
     if (item) {
       return item.desc;
     } else {
       return null;
    }
   }),

   optionMin: computed('optionString',function() {
     let list = A(this.opList);
     let item = list.findBy('name', this.optionString);
     if (item) {
       return item.ranks[0];
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

  @action
  abilityChanged() {
    this.validateChar();
  },

  @action
  doSelectOption() {
    this.set('selectOption', true);
  },

  @action
  cancelSelectOption() {
    this.set('selectOption', false);
  },

  @action
  changeOptionString(event) {
    this.set('optionString', event.target.value);
  },

  @action
  addOption() {
    let convList = A(this.opList);
    let option_list = convList.mapBy('name');
    let optionString = this.optionString || option_list[0];
    let optionDetails = this.optionDetails || null;
    let optionMin = 1;
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
       optionMin = this.optionMin;
       if (!optionDetails) {
          this.flashMessages.danger("You have to specify details for the " + this.type + ".");
          this.set('selectOption', false);
          return;
       }
    }
    this.set('optionDetails', null);
    this.set('selectOption', false);
    pushObject( this.charList, EmberObject.create( { name: optionString, rating: optionMin, details: optionDetails } ) , this, 'charList' );
    this.validateChar();
  }

});
