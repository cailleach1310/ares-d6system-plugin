module AresMUSH
  module D6System
    class SetJobDamageRequestHandler
      def handle(request)
        job = Job[request.args[:id]]
        enactor = request.enactor
        
        error = Website.check_login(request)
        return error if error

        request.log_request
        
        if (!enactor.is_admin?)
          return { error: t('dispatcher.not_allowed') }
        end
        
        if (!job)
          return { error: t('webportal.not_found') }
        end
        
        if (!job.is_open?)
          return { error: t('jobs.job_already_closed') }
        end
        
        result = D6System.set_damage_web(request, enactor, 'job')
        
        return result if result[:error]

        Jobs.comment(job, Game.master.system_character, result[:message], false)
        
        {
        }
      end
    end
  end
end
