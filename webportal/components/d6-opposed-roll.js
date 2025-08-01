import Component from '@ember/component';
import { inject as service } from '@ember/service';
import { action } from '@ember/object';

export default Component.extend({
    gameApi: service(),
    flashMessages: service(),
    tagName: '',
    selectAddOpposed: false,
    vsRoll1: null,
    vsRoll2: null,
    vsName1: null,
    vsName2: null,
    destinationType: 'scene',

    didInsertElement: function() {
      this._super(...arguments);
      let defaultAbility = this.abilities ? this.abilities[0] : '';
    },

    @action
    cancelOpposedRoll() {
       this.set('selectAddOpposed', false);
    },

    @action
    addOpposedRoll() {
      let api = this.gameApi;
      let defaultAbility = this.abilities ? this.abilities[0] : '';
    
      // Needed because the onChange event doesn't get triggered when the list is 
      // first loaded, so the roll string is empty.
      let vsRoll1 = this.vsRoll1;
      let vsRoll2 = this.vsRoll2;
      let vsName1 = this.vsName1;
      let vsName2 = this.vsName2;

      var sender;
      if (this.scene) {
        sender = this.get('scene.poseChar.name');
      }
        
      if (!vsRoll1 && !vsRoll2) {
        this.flashMessages.danger("You haven't selected an ability to roll.");
        return;
      }
    
      if (vsRoll1 || vsRoll2 || vsName1 || vsName2) {
        if (!vsRoll2 || !vsName1 || !vsName2) {
          this.flashMessages.danger("You have to provide all opposed skill information.");
          return;
        }
      }

      this.set('selectAddOpposed', false);
      this.set('vsRoll1', null);
      this.set('vsRoll2', null);
      this.set('vsName1', null);
      this.set('vsName2', null);
      var destinationId, command;
      if (this.destinationType == 'scene') {
        destinationId = this.get('scene.id');
        command = 'addSceneRoll';
      }
      else {
        destinationId = this.get('job.id');
        command = 'addJobRoll'
      }
      
      api.requestOne(command, { id: destinationId,
         roll_string: null,
         difficulty: null,
         vs_roll1: vsRoll1,
         vs_roll2: vsRoll2,
         vs_name1: vsName1,
         vs_name2: vsName2,
         pc_name: null,
         pc_ability: null,
         fate: null,
         cp: null,
         sender: sender }, null)
      .then( (response) => {
        if (response.error) {
          return;
        }
      });
    }
});
