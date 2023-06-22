import EmberObject, { computed } from '@ember/object';
import { A } from '@ember/array';
import Component from '@ember/component';
import { inject as service } from '@ember/service';

export default Component.extend({
  tagName: '',
  flashMessages: service(),
  gameApi: service(),
  
  didInsertElement: function() {
    this._super(...arguments);
    let self = this;
    this.set('updateCallback', function() { return self.onUpdate(); } );
   },
 
  attrPoints: computed('char.custom.d6.attrs.@each.rating', function() {
    let total = this.countDiceInGroup(this.get('char.custom.d6.attrs')) * 4;
    return total;
  }),
    
  attrDice: computed('char.custom.d6.attrs.@each.rating', function() {
    let total = this.countDiceInGroup(this.get('char.custom.d6.attrs'));
    return total;
  }),

  skillPoints: computed('char.custom.d6.skills.@each.rating', function() {
    let total = this.countDiceInGroup(this.get('char.custom.d6.skills'));
    return total;
  }),

  skillDice: computed('char.custom.d6.skills.@each.rating', function() {
    let total = this.countDiceInGroup(this.get('char.custom.d6.skills'));
    return total;
  }),

  advPoints: computed('char.custom.d6.advantages.@each.rating', function() {
    let total = this.countPointsInGroup(this.get('char.custom.d6.advantages'));
    return total;
  }),

   countDiceInGroup: function(list) {
    if (!list) {
      return 0;
    }
    let total_dice = 0;
    let total_pips = 0;
    list.forEach(function (ability) {
      let dice = parseInt(ability.rating.split("D")[0]);
      let pips = parseInt(ability.rating.split("+")[1]);
      total_dice = total_dice + dice;
      total_pips = total_pips + pips;
    });
    total_dice = total_dice + Math.floor(total_pips / 3);
    if (total_pips % 3 > 0) {
       total_dice = total_dice + 1;
    }
    return total_dice;
  },

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

  onUpdate: function() {
    return {
      attrs: this.createAbilityHash(this.get('char.custom.d6.attrs')),
      skills: this.createAbilityHash(this.get('char.custom.d6.skills')),
      advantages: this.createAbilityHash(this.get('char.custom.d6.advantages'))
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

     
  checkLimits: function(list, limits, title) {
//    if (!list) {
//      return;
//    }

//    for (var high_rating in limits) {
//      let limit = limits[high_rating];
//      let high = list.filter(l => l.rating >= high_rating);
//      let count = high.length;
//      if (count > limit) {
//        this.charErrors.push(`You can only have ${limit} ${title} at ${high_rating}+.`);
//      }
//    }
  },
    
  validateChar: function() {
// lots of stuff to be added here later!
    this.set('charErrors', A());

  },
    
  actions: {

    abilityChanged() {
      this.validateChar();
    },

    reset() {
      this.reset();
    },

    reloadChar() {
      this.reloadChar();
    }
  }
    
});
