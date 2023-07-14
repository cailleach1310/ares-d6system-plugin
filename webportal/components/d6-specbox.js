import Component from '@ember/component';

export default Component.extend({
    
    actions: { 
        removeSpecialization() {
           this.set('rating', '0D+0');
           this.updated();
        }
    }
});
