# Remove Previous Non-Custom Modification of the Webportal Job Menu (pre-AresMUSH v.1.2.0) 
If you had this feature applied, follow the steps outlined below to clean up your system when upgrading to v.1.2.0.

### Remove /aresmush/plugins/jobs/custom_job_check.rb
Before you remove it, you can copy/paste the contents of the file to the official custom_job_data.rb or simply use the one in the folder custom_files to replace it.

### Rollback /aresmush/plugins/jobs/web/job_request_handler.rb
Remove the line 'custom: Jobs.custom_job_check(enactor),' or replace the file with the new official job_request_handler.rb from the main Aresmush repository.

### Remove /ares-webportal/app/templates/components/job-add-custom-check.hbs
Use the new file job-menu-custom.hbs from the custom_files folder in this repository to replace the one in the game after running the upgrade.

### Remove /ares-webportal/app/components/job-add-custom-check.js
You can either copy/paste the contents from this file to the file job-menu-custom.js or replace it with the one in the custom_files folder of this repository.

### Rollback /ares-webportal/app/templates/job.hbs
Remove the following code from the file:

      {{#if this.model.job.custom}}
        <JobAddCustomCheck @job={{this.model.job}} @custom={{this.model.job.custom}}/>
      {{/if}}


This needs to be adjusted in two places, because there is a job menu at the top and one at the bottom.

Alternatively, replace this file with the new official job.hbs from the main AresMUSH repository.
