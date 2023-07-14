import Component from '@ember/component';
import EmberObject, { computed } from '@ember/object';

export default Component.extend({

  attrSkills: computed('attribute',function() {
    let attribute = this.get('attribute');
    let list = this.get('skills');
    return list.filterBy('linked_attr', attribute);
  }),

  actions: {

    abilityChanged() {
      this.updated();
    }
  }
});
