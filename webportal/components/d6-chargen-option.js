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
    let total = this.countPointsInGroup(this.get('charList'));
    if (this.type == 'special ability') {
      total = total * (-1); // needs to be replaced with cost (general or for the first rank)
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

  onUpdate: function() {
    return {
//      advantages: this.createAbilityHash(this.get('char.custom.d6.advantages'))
    };
  },
    
  createAbilityHash: function(ability_list) {
    if (!ability_list) {
      return {};
    }
    return ability_list.reduce(function(map, obj) {
      if (obj.name && obj.name.length > 0) {
        map[obj.name] = obj.rating;
      }
      return map;
    }, 
    {}
              
    );
  },

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
        this.flashMessages.danger("You didn't specify a valid " + this.type + ".");
        this.set('selectOption', false);
        return;
      }
      if (!optionString.match(/^[\w\s]+$/)) {
        this.flashMessages.danger("Options can't have special characters in their names.");
        this.set('selectOption', false);
        return;
      }
      if (!optionDetails) {
        this.flashMessages.danger("You didn't specify details for the " + this.type + ".");
        this.set('selectOption', false);
        return;
      }
      this.set('optionDetails', null);
      this.set('selectOption', false);
      this.get('charList').pushObject( EmberObject.create( { name: optionString, rating: 1, details: optionDetails }) );
      this.validateChar();
    }

//   selectAdv(name) {
//     this.set('advString',name);
//     let item = this.get('char.custom.cg_d6.advantages').findBy('name',name);
//     this.set('advDesc', item.desc);
//   },

  }
    
});
