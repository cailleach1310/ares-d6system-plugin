module AresMUSH
  module D6System
    class NaturalHealJobRequestHandler
      def handle(request)
        scene = Scene[request.args[:id]]
        enactor = request.enactor
        
        job = Job[request.args['id']]
        enactor = request.enactor
        
        error = Website.check_login(request)
        return error if error

        request.log_request
        
        if (!job)
          return { error: t('webportal.not_found') }
        end
        
        if (!Jobs.can_access_job?(enactor, job, true))
          return { error: t('jobs.cant_view_job') }
        end
        
        if (!job.is_open?)
          return { error: t('jobs.job_already_closed') }
        end

        result = D6System.web_natural_heal(request, enactor)
        
        return result if result[:error]

        Jobs.comment(job, Game.master.system_character, result[:message], false)
        
        {
        }
      end
    end
  end
end
