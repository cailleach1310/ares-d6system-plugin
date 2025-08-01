import EmberObject, { computed, action } from '@ember/object';
import Component from '@ember/component';
import { inject as service } from '@ember/service';

export default Component.extend({
    gameApi: service(),
    flashMessages: service(),
    tagName: '',
    selectHeal: false,
    healFate: false,
    healCp: false,
    healName: null,
    destinationType: 'scene',

    didInsertElement: function() {
      this._super(...arguments);
      let defaultChar = this.scene ? this.scene.participants[0] : null;
      let defaultName = defaultChar ? defaultChar.name : null;
      this.set('healName', defaultName);
    },

    @action
    onHealNameSelected() {
      this.set('healName', event.target.value);
    },

    @action
    cancelHeal() {
      this.set('selectHeal', false);
    },

    @action
    healChar() {
      let api = this.gameApi;
      let defaultChar = this.scene ? this.scene.participants[0] : null;
      let defaultName = defaultChar ? defaultChar.name : null;
      // Needed because the onChange event doesn't get triggered when the list is 
      // first loaded, so the roll string is empty.
      let healName = this.healName || defaultName;
      let healFate = this.healFate;
      let healCp = this.healCp;

      var sender;
      if (this.scene) {
        sender = this.get('scene.poseChar.name');
      }
        
      if (!healName) {
        this.flashMessages.danger("You haven't entered a name.");
        return;
      }
    
      this.set('selectHeal', false);
      this.set('healFate', false);
      this.set('healCp', false);
      this.set('healName', defaultName);
      var destinationId, command;
      if (this.destinationType == 'scene') {
        destinationId = this.get('scene.id');
        command = 'healSceneChar';
      }
      else {
        destinationId = this.get('job.id');
        command = 'healJobChar';
      }
      
      api.requestOne(command, { id: destinationId,
         heal_name: healName,
         fate: healFate,
         cp: healCp,
         sender: sender }, null)
      .then( (response) => {
        if (response.error) {
          return;
        }
      });
  }

});
