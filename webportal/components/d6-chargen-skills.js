import Component from '@ember/component';
import EmberObject, { computed, action } from '@ember/object';
import { A } from '@ember/array';

export default Component.extend({

  attrSkills: computed('attribute',function() {
    let attribute = this.get('attribute');
    let list = A(this.get('skills'));
    return list.filterBy('linked_attr', attribute);
  }),

  @action
  abilityChanged() {
    this.updated();
  }
});
