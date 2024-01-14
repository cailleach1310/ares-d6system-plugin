import EmberObject, { computed } from '@ember/object';
import Component from '@ember/component';
import { inject as service } from '@ember/service';

export default Component.extend({
    gameApi: service(),
    flashMessages: service(),
    tagName: '',
    selectNaturalHeal: false,
    rollString: 'Physique',
    healFate: false,
    healCp: false,
    destinationType: 'job',

    didInsertElement: function() {
      this._super(...arguments);
      this.set('rollString', 'Physique');
    },


    actions: { 
      
      rollNaturalHeal() {
        let api = this.gameApi;
      
        // Needed because the onChange event doesn't get triggered when the list is 
        // first loaded, so the roll string is empty.
        let healFate = this.healFate;
        let healCp = this.healCp;
        let rollString = this.rollString

        
        var sender;
        if (this.scene) {
          sender = this.get('scene.poseChar.name');
        }
          
        this.set('selectNaturalHeal', false);
        this.set('healFate', false);
        this.set('healCp', false);
        this.set('rollStr', 'Physique');

        var destinationId, command;
        if (this.destinationType == 'scene') {
          destinationId = this.get('scene.id');
          command = 'rollNaturalHealScene';
        }
        else {
          destinationId = this.get('job.id');
          command = 'rollNaturalHealJob';
        }
        
        api.requestOne(command, { id: destinationId,
           fate: healFate,
           cp: healCp,
           roll_str: rollString,
           sender: sender }, null)
        .then( (response) => {
          if (response.error) {
            return;
          }
        });
      },
    }
});
