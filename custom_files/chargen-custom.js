import EmberObject, { computed } from '@ember/object';
import { helper } from '@ember/component/helper';
import { A } from '@ember/array';
import Component from '@ember/component';
import { inject as service } from '@ember/service';

export default Component.extend({
  tagName: '',
  newSpecialization: null,
  specSkillString: null, 
  selectSpecialization: false,
  advDetails: null,
  advString: null,
  advDesc: null,
  selectAdvantage: false,
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

  specPoints: computed('char.custom.d6.specializations.@each.rating', function() {
    let total = Math.ceil(this.countDiceInGroup(this.get('char.custom.d6.specializations')) / 3);
    return total;
  }),

  specDice: computed('char.custom.d6.specializations.@each.rating', function() {
    let total = this.countDiceInGroup(this.get('char.custom.d6.specializations'));
    return total;
  }),

  advPoints: computed('char.custom.d6.advantages.@each.rating', function() {
    let total = this.countPointsInGroup(this.get('char.custom.d6.advantages'));
    return total;
  }),

  disAdvantagePoints: computed('char.custom.d6.disadvantages.@each.rating', function() {
    let total = this.countPointsInGroup(this.get('char.custom.d6.disadvantages'));
    return total;
  }),

  specAbilityPoints: computed('char.custom.d6.special_abilities.@each.rating', function() {
    let total = this.countPointsInGroup(this.get('char.custom.d6.special_abilities'));
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

   optionDesc: computed('advString',function() {
     let list = this.get('char.custom.cg_d6.advantages');
     let item = list.findBy( 'name', this.advString);
     if (item) {
       return item.desc;
     } else {
       return null;
    }
   }),

//   advDesc: computed('this.advString', function() {
//     let item = this.get('char.custom.cg_d6.advantages').findBy('name',this.advString);
//     return item;
//   }),

  onUpdate: function() {
    return {
      attrs: this.createAbilityHash(this.get('char.custom.d6.attrs')),
      skills: this.createAbilityHash(this.get('char.custom.d6.skills')),
      specializationss: this.createAbilityHash(this.get('char.custom.d6.specializations')),
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

    addSpecialization() {
      let skill_list = this.get('char.custom.cg_d6.skillnames');
      let specSkillString = this.specSkillString || skill_list[0];
      let spec = this.newSpecialization;
      let skill = this.specSkillString;
      if (!spec) {
        this.flashMessages.danger("You didn't specify a specialization name.");
        this.set('selectSpecialization', false);
        return;
      }
      if (!spec.match(/^[\w\s]+$/)) {
        this.flashMessages.danger("Specializations can't have special characters in their names.");
        this.set('selectSpecialization', false);
        return;
      }
      if (!skill) {
        this.flashMessages.danger("You didn't specify a skill for the specialization.");
        this.set('selectSpecialization', false);
        return;
      }
      this.set('newSpecialization', null);
      this.set('selectSpecialization', false);
      this.get('char.custom.d6.specializations').pushObject( EmberObject.create( { name: spec + " (" + skill + ")", rating: '0D+1' }) );  
      this.validateChar();
    },

    addAdvantage() {
      let adv_list = this.get('char.custom.cg_d6.advantages').mapBy('name');
      let advString = this.advSelected.name || adv_list[0];
      let advDetails = this.advDetails || null;
      if (!advString) {
        this.flashMessages.danger("You didn't specify an advantage.");
        this.set('selectAdvantage', false);
        return;
      }
      if (!advString.match(/^[\w\s]+$/)) {
        this.flashMessages.danger("Advantages can't have special characters in their names.");
        this.set('selectAdvantage', false);
        return;
      }
      if (!advDetails) {
        this.flashMessages.danger("You didn't specify details for the advantage.");
        this.set('selectAdvantage', false);
        return;
      }
      this.set('advDetails', null);
      this.set('selectAdvantage', false);
      this.set('advSelected', null);
      this.get('char.custom.d6.advantages').pushObject( EmberObject.create( { name: advString, rating: 1, details: advDetails }) );
      this.validateChar();
    },

//   selectAdv(name) {
//     this.set('advString',name);
//     let item = this.get('char.custom.cg_d6.advantages').findBy('name',name);
//     this.set('advDesc', item.desc);
//   },

    reset() {
      this.reset();
    },

    reloadChar() {
      this.reloadChar();
    }
  }
    
});
