# Optional: Add Roll Ability to the Webportal Job Menu 
This is how you can enable adding ability rolls to jobs from the webportal, similar to how it can be done with fs3 rolls. As there is no custom job menu as of yet, this means that the steps outlined below require adjustments of non-custom code parts. Future upgrades of AresMUSH might run into merge conflicts, so these upgrades require extra attention.

## Creating and Modifying Files in the Jobs Plugin (aresmush)

### Create /aresmush/plugins/jobs/custom_job_check.rb
Create this file in the specified folder and copy/paste the contents of custom_job_check.rb in this folder (non_custom).

### Modify /aresmush/plugins/jobs/web/job_request_handler.rb
Insert the line 'custom: Jobs.custom_job_check(enactor),' as lined out below:

     module AresMUSH
       module Jobs
         class JobRequestHandler
           def handle(request)

          (...)
            {
              id: job.id,
              title: job.title,
              unread: job.is_unread?(enactor),
              category: job.job_category.name,
              status: job.status,
              created: job.created_date_str(enactor),
              is_open: job.is_open?,
              is_job_admin: is_job_admin,
              fs3_enabled: FS3Skills.is_enabled?,
              custom: Jobs.custom_job_check(enactor),
              is_category_admin: Jobs.can_access_category?(enactor, job.job_category),
              is_approval_job: job.author && !job.author.is_approved? && (job.author.approval_job == job),
              is_roster_job: roster_char && job.is_open?,
              roster_name: roster_char ? roster_char.name : nil,
              author: { name: job.author_name, id: job.author ? job.author.id : nil, icon: Website.icon_for_char(job.author) },
              assigned_to: job.assigned_to ? { name: job.assigned_to.name, icon: Website.icon_for_char(job.assigned_to) } : nil,
              description: description,
              tags: job.content_tags,
              unread_jobs_count: is_job_admin ? enactor.unread_jobs.count : enactor.unread_requests.count,
              replies: Jobs.visible_replies(enactor, job).map { |r| {
                author: { name: r.author_name, icon: Website.icon_for_char(r.author) },
                message: Website.format_markdown_for_html(r.message),
                created: r.created_date_str(enactor),
                admin_only: r.admin_only,
                id: r.id
              }},
              participants: job.participants.map { |p| {
                name: p.name,
                icon: Website.icon_for_char(p),
                id: p.id
              }},
              job_admins: job_admins.map { |c|  {
                id: c.id,
                name: c.name
                }},
              responses: Jobs.preset_job_responses_for_web
            }
      (...)

## Creating and Modifying Files in the Webportal

### Creating /ares-webportal/app/templates/components/job-add-custom-check.hbs
Create this file in the specified folder and copy/paste the contents of job-add-custom-check.hbs in this folder (non_custom).

### Creating /ares-webportal/app/components/job-add-custom-check.js
Create this file in the specified folder and copy/paste the contents of job-add-custom-check.js in this folder (non_custom).

### Modifying /ares-webportal/app/templates/job.hbs
Add the following code to the file:

      {{#if this.model.job.custom}}
        <JobAddCustomCheck @job={{this.model.job}} @custom={{this.model.job.custom}}/>
      {{/if}}


Add the code as lined out below. This needs to be adjusted in two places, because there is a job menu at the top and one at the bottom.

      <div class="display-job-controls">
       {{#if this.model.job.is_open }}

         <DropdownMenu @id="jobMenu" @title="Job Menu">

                <li><a href="#" {{action 'closeJob'}}  class="dropdown-item">Close Job</a></li>
                {{#if this.model.job.is_job_admin}}
                  <li><LinkTo @route="job-edit" @model={{this.model.job.id}} class="dropdown-item">Edit Job</LinkTo></li>
                {{/if}}
                {{#if this.model.job.fs3_enabled}}
                  <li><a href="#" {{action (mut this.selectSkillRoll) true}} class="dropdown-item">Add Ability Roll</a></li>
                {{/if}}
                {{#if this.model.job.custom}}
                  <JobAddCustomCheck @job={{this.model.job}} @custom={{this.model.job.custom}}/>
                {{/if}}
                {{#if this.model.job.is_approval_job}}
                  <li><LinkTo @route="app-review" @model={{this.model.job.author.id}} class="dropdown-item">App Review for {{this.model.job.author.name}}</LinkTo></li>
                  <li><LinkTo @route="char" @model={{this.model.job.author.name}} class="dropdown-item">Profile for {{this.model.job.author.name}}</LinkTo></li>
                {{/if}}
                {{#if this.model.job.is_roster_job}}
                  <li><a href="#" {{action 'approveRoster'}} class="dropdown-item">Approve Roster for {{this.model.job.roster_name}}</a></li>
                  <li><a href="#" {{action 'rejectRoster'}} class="dropdown-item">Reject Roster for {{this.model.job.roster_name}}</a></li>
                {{/if}}

         </DropdownMenu>
      {{/if}}
      </div>


