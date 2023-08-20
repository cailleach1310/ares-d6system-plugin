module AresMUSH
  module D6System
    class SetWoundLevelCmd
      include CommandHandler
      
      attr_accessor :name, :wound_level

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2)
        self.name = args.arg1
        self.wound_level = args.arg2
      end

      def required_args
        [ self.name, self.wound_level ]
      end

      def check_can_set
        return nil if enactor.is_admin?
        return t('dispatcher.not_allowed')
      end
      
      def handle
        if !D6System.wound_levels.map { |a| a["name"] }.include?(self.wound_level)
           client.emit_failure "That is not a valid wound level!"
           return
        end
        
        ClassTargetFinder.with_a_character(self.name, client, enactor) do |model|
          D6System.wound_set(model, self.wound_level)
          Global.logger.info "#{enactor.name} sets #{model.name}'s wound level to #{model.wound_level}."
          client.emit_success "You've set #{model.name}'s wound level to #{model.wound_level}."
          message = "#{enactor.name} sets #{model.name}'s wound level to #{model.wound_level}."
          enactor_room.emit message
          if (enactor_room.scene)
            Scenes.add_to_scene(enactor_room.scene, message)
          end
        end
      end

    end
  end
end
