import EmberObject, { computed } from '@ember/object';
import { A } from '@ember/array';
import Component from '@ember/component';
import { inject as service } from '@ember/service';

export default Component.extend({
  tagName: '',
  newSpecialization: null,
  specSkillString: null, 
  selectSpecialization: false,
  flashMessages: service(),
  gameApi: service(),
  
  didInsertElement: function() {
    this._super(...arguments);
    let self = this;
    let specSkillString = this.specSkillString || this.char.skills[0].name; 
    this.set('updateCallback', function() { return self.onUpdate(); } );
   },

  attrPoints: computed('char.attrs.@each.rating', function() {
    let total = this.countDiceInGroup(this.get('char.attrs')) * 4;
    return total;
  }),

  attrDice: computed('char.attrs.@each.rating', function() {
    let total = this.countDiceInGroup(this.get('char.attrs'));
    return total;
  }),

  skillPoints: computed('char.skills.@each.rating', function() {
    let total = this.countDiceInGroup(this.get('char.skills'));
    return total;
  }),

  skillDice: computed('char.skills.@each.rating', function() {
    let total = this.countDiceInGroup(this.get('char.skills'));
    return total;
  }),

  specPoints: computed('char.specializations.@each.rating', function() {
    let total = Math.ceil(this.countDiceInGroup(this.get('char.specializations')) / 3);
    return total;
  }),

  specDice: computed('char.specializations.@each.rating', function() {
    let total = this.countDiceInGroup(this.get('char.specializations'));
    return total;
  }),

  getSpecBase: computed('specSkillString', function() {
    let skillName = this.get('specSkillString');
    let item = this.get('char.skills').findBy('name', skillName);
    if (item) {
       let attr = this.get('char.attrs').findBy('name', item.linked_attr);
       if (attr) {
          let combDice = parseInt(item.rating.split("D")[0]) + parseInt(attr.rating.split("D")[0]);
          let combPips = parseInt(item.rating.split("+")[1]) + parseInt(attr.rating.split("+")[1]);
          if (combPips > 2) {
             combDice = combDice + 1;
             combPips = combPips - 3;
          }
          return combDice.toString() + "D+" + combPips.toString();
       }
    }
    return '0D+0';
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

  validateChar: function() {
    this.set('charErrors', A());
  },

  actions: {

    abilityChanged() {
      this.updated();
    },

    resetD6Abilities(id) {
      let api = this.gameApi;
      api.requestOne('resetD6Abilities', { name: id }, null)
          .then( (response) => {
              if (response.error) {
                  return;
              }
              this.flashMessages.success(response.name + "'s abilities have been reset! Please reload the page!");
          });
    },

    addSpecialization() {
      let skill_list = this.get('cg_info.skillnames');
      let specSkillString = this.specSkillString || skill_list[0];
      let spec = this.newSpecialization;
      let skill = this.specSkillString;
      let baseRating = this.get('getSpecBase');
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
      this.get('char.specializations').pushObject( EmberObject.create( { name: spec + " (" + skill + ")", rating: '0D+1', base_rating: baseRating }) );
      this.validateChar();
    }

  }

});
