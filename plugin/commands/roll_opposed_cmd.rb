module AresMUSH
  module D6System
    class OpposedRollCmd
      include CommandHandler
      
      attr_accessor :name1, :name2, :roll_str1, :roll_str2, :private_roll

      def parse_args
        args = cmd.parse_args( /(?<name1>[^\/]+)\/(?<str1>.+) vs (?<name2>[^\/]+)?\/?(?<str2>.+)/ )
        self.roll_str1 = titlecase_arg(args.str1)
        self.roll_str2 = titlecase_arg(args.str2)
        self.name1 = titlecase_arg(args.name1)
        self.name2 = titlecase_arg(args.name2)
        self.private_roll = cmd.switch_is?("private")
      end

      def required_args
        [ self.name1, self.roll_str1, self.roll_str2 ]
      end
      
      def handle
        message = ""
        char1 = Character.named(self.name1)
        char2 = Character.named(self.name2)

        if ( (!char1 && !D6System.valid_num_roll_str(self.roll_str1)) || 
             (!char2 && !D6System.valid_num_roll_str(self.roll_str2)) )
          client.emit_failure t('d6system.numbers_only_for_npc_skills')
          return
        end

        if (char1)
          if D6System.exceeds_roll_limit(char1, self.roll_str1)
              message = message + t('d6system.exceeds_roll_limit',
                 :name => char1.name,
                 :max => Global.read_config("d6system", "roll_max_dice")
              ) + "%r"
          end
        end

        if (char2)
          if D6System.exceeds_roll_limit(char2, self.roll_str2)
              message = message + t('d6system.exceeds_roll_limit',
                 :name => char2.name,
                 :max => Global.read_config("d6system", "roll_max_dice")
              ) + "%r"
          end
        end
          
        roll_msg = D6System.emit_opposed_roll(self.name1, self.roll_str1, self.name2, self.roll_str2, enactor)
        if !roll_msg
          client.emit_failure t('d6system.unknown_roll_params')
          return
        end
        message = message + roll_msg
        D6System.emit_results message, client, enactor_room, self.private_roll
      end
    end
  end
end
