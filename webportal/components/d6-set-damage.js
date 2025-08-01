import EmberObject, { computed, action } from '@ember/object';
import Component from '@ember/component';
import { inject as service } from '@ember/service';

export default Component.extend({
    gameApi: service(),
    flashMessages: service(),
    tagName: '',
    selectDamage: false,
    damageString: null,
    nameString: null,
    destinationType: 'scene',

    didInsertElement: function() {
      this._super(...arguments);
      let defaultDamage = this.woundLevels ? this.woundLevels[0] : '';
      this.set('damageString', defaultDamage);
      let defaultChar = this.scene ? this.scene.participants[0] : null;
      let defaultName = defaultChar ? defaultChar.name : null;
      this.set('nameString', defaultName);
    },

    @action
    cancelDamage() {
       this.set('selectDamage', false);
    },

    @action
    changeNameString() {
       this.set('nameString', event.target.value);
    },

    @action
    changeDamageString() {
       this.set('damageString', event.target.value);
    },

    @action
    setDamage() {
       let api = this.gameApi;
       let defaultDamage = this.woundLevels ? this.woundLevels[0] : '';
       let defaultChar = this.scene ? this.scene.participants[0] : null;
       let defaultName = defaultChar ? defaultChar.name : null;
     
       // Needed because the onChange event doesn't get triggered when the list is 
       // first loaded, so the roll string is empty.
       let damageString = this.damageString || defaultDamage;
       let nameString = this.nameString || defaultName;
       
       var sender;
       if (this.scene) {
         sender = this.get('scene.poseChar.name');
       }
         
       if (!damageString) {
         this.flashMessages.danger("You haven't selected a wound level.");
         return;
       }
     
       if (!damageString || !nameString) {
         this.flashMessages.danger("You have to provide all information to set a wound level for a PC.");
         return;
       }
       this.set('selectDamage', false);
       this.set('damageString', this.woundLevels[0]);
       this.set('nameString', defaultName);
        var destinationId, command;
       if (this.destinationType == 'scene') {
         destinationId = this.get('scene.id');
         command = 'setSceneDamage';
       }
       else {
         destinationId = this.get('job.id');
         command = 'setJobDamage';
       }
       
       api.requestOne(command, { id: destinationId,
          char_name: nameString,
          wound_level: damageString,
          sender: sender }, null)
       .then( (response) => {
         if (response.error) {
           return;
         }
       });
    }

});
