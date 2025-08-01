import Component from '@ember/component';
import { inject as service } from '@ember/service';
import { action } from '@ember/object';

export default Component.extend({
    gameApi: service(),
    flashMessages: service(),
    tagName: '',
    selectAddRoll: false,
    pcRollAbility: null,
    pcRollName: null,
    pcDifficulty: null,
    rollString: null,
    rollFate: false,
    rollChar: false,
    rollDiff: false,
    pcRollDiff: false,
    difficulty: null,
    destinationType: 'scene',

    didInsertElement: function() {
      this._super(...arguments);
      let defaultAbility = this.abilities ? this.abilities[0] : '';
      this.set('rollString', defaultAbility);
    },

    @action
    cancelAddRoll() {
      this.set('selectAddRoll', false);
    },

    @action
    changeRollStr() {
      this.set('rollStr', event.target.value);
    },

    @action
    addRoll() {
      let api = this.gameApi;
      let defaultAbility = this.abilities ? this.abilities[0] : '';
    
      // Needed because the onChange event doesn't get triggered when the list is 
      // first loaded, so the roll string is empty.
      let rollString = this.rollString || defaultAbility;
      let pcRollAbility = this.pcRollAbility;
      let pcRollName = this.pcRollName;
      let pcDifficulty = this.pcDifficulty
      let rollFate = this.rollFate;
      let rollChar = this.rollChar;
      let rollDiff = false;
      let pcRollDiff = false;
      let difficulty = this.difficulty;

      var sender;
      if (this.scene) {
        sender = this.get('scene.poseChar.name');
      }
        
      if (!rollString && !pcRollAbility) {
        this.flashMessages.danger("You haven't selected an ability to roll.");
        return;
      }
    
      if (pcRollAbility || pcRollName) {
        if (!pcRollAbility || !pcRollName) {
          this.flashMessages.danger("You have to provide all skill information to roll for a PC.");
          return;
        }
      }

      this.set('selectAddRoll', false);
      this.set('rollString', null);
      this.set('pcRollAbility', null);
      this.set('pcRollName', null);
      this.set('rollChar', false);
      this.set('rollFate', false);
      this.set('rollDiff', false);
      this.set('pcRollDiff', false);
      this.set('difficulty', null);
      this.set('pcDifficulty', null);
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
         roll_string: rollString,
         difficulty: difficulty || pcDifficulty,
         vs_roll1: null,
         vs_roll2: null,
         vs_name1: null,
         vs_name2: null,
         pc_name: pcRollName,
         pc_ability: pcRollAbility,
         fate: rollFate,
         cp: rollChar,
         sender: sender }, null)
      .then( (response) => {
         if (response.error) {
           return;
         }
     });
    }

});
