module AresMUSH
  module D6System
    class SetSceneDamageRequestHandler
      def handle(request)
        scene = Scene[request.args[:id]]
        enactor = request.enactor
        sender_name = request.args[:sender]
        
        error = Website.check_login(request)
        return error if error

        request.log_request
        
        sender = Character.named(sender_name)
        if (!sender)
          return { error: t('webportal.not_found') }
        end
        
        if (!enactor.is_admin?)
          return { error: t('dispatcher.not_allowed') }
        end
        
        if (!scene)
          return { error: t('webportal.not_found') }
        end
        
        if (!Scenes.can_read_scene?(enactor, scene))
          return { error: t('scenes.access_not_allowed') }
        end
        
        if (scene.completed)
          return { error: t('scenes.scene_already_completed') }
        end
        
        result = D6System.set_damage_web(request, sender, 'scene')
        
        return result if result[:error]

        D6System.emit_results(result[:message], nil, scene.room, false)
        
        {
        }
      end
    end
  end
end
