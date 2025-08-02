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

  onUpdate: function() {
    return {
      attrs: this.createAbilityHash(this.get('char.custom.d6.attrs')),
      skills: this.createAbilityHash(this.get('char.custom.d6.skills')),
      specializations: this.createAbilityHash(this.get('char.custom.d6.specializations')),
      advantages: this.createOptionHash(this.get('char.custom.d6.advantages')),
      disadvantages: this.createOptionHash(this.get('char.custom.d6.disadvantages')),
      special_abilities: this.createOptionHash(this.get('char.custom.d6.special_abilities'))
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

  createOptionHash: function(option_list) {
    if (!option_list) {
      return {};
    }
    return option_list.reduce(function(map, obj) {
      if (obj.name && obj.name.length > 0) {
        let optionStuff = obj.rating.toString() + ":" + obj.details;
        map[obj.name] = optionStuff;
      }
      return map;
    },
    {}

    );
  },

  validateChar: function() {
    this.set('charErrors', A());
  },

  @action
  abilityChanged() {
     this.validateChar();
  }

});
