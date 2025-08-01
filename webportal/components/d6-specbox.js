import Component from '@ember/component';
import { action } from '@ember/object';

export default Component.extend({
    
    @action
    removeSpecialization() {
       this.set('rating', '0D+0');
       this.updated();
    }
});
