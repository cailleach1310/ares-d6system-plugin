module AresMUSH
  module D6System
    class RollCmd
      include CommandHandler
      
      attr_accessor :name, :roll_str, :difficulty, :fate_roll, :cp_roll, :private_roll

      def parse_args
        if (cmd.args =~ /\//)
          args = cmd.parse_args(/(?<arg1>[^\/\=]+)\/(?<arg2>[^\=]+)\=?(?<arg3>.+)?/)  # arg1_slash_arg2_equals_optional_arg3        
          self.name = titlecase_arg(args.arg1)
          if !Character.named(self.name)
             self.name = t('d6system.npc', :name => self.name)
          end
          self.roll_str = titlecase_arg(args.arg2)
          self.difficulty = args.arg3 ? integer_arg(args.arg3) : 0
        else
          args = cmd.parse_args(ArgParser.arg1_equals_optional_arg2)
          self.name = enactor.name
          self.roll_str = titlecase_arg(args.arg1)
          self.difficulty = args.arg2 ? integer_arg(args.arg2) : 0
        end
        self.private_roll = cmd.switch_is?("private")
        self.fate_roll = cmd.switch_is?("fate") || cmd.switch_is?("all")
        self.cp_roll = cmd.switch_is?("cp") || cmd.switch_is?("all")
      end
      
      def required_args
        [ self.name, self.roll_str ]
      end
      
      def handle
        message = ""
        char = Character.named(self.name)

        if (char)
           # roll limit
           if ( !D6System.valid_num_roll_str(self.roll_str) && D6System.exceeds_roll_limit(char, self.roll_str) )
              message = message + t('d6system.exceeds_roll_limit',
                :name => self.name ? self.name : enactor.name,
                :max => Global.read_config("d6system", "roll_max_dice")
              ) + "%r"
           end

           # wound modifier
           modifier = D6System.get_wound_modifier(char)
           if (modifier != 0)
              self.roll_str = D6System.add_modifier_dice(self.roll_str, modifier)
              message = message + t('d6system.wound_modifier',
                :name => char.name,
                :level => char.wound_level.downcase,
                :modifier => modifier
              ) + "%r"              
           end

           # cp roll
           if (self.cp_roll && (char == enactor))
              if (char.char_points > 0)
                 char.update(char_points: char.char_points - 1)
                 Achievements.award_achievement(char, "d6_cp_spent")
                 message = message + t('d6system.spends_char_point', :name => char.name) + "%r"
                 self.roll_str = D6System.add_modifier_dice(self.roll_str, 1)       # modify roll_str, add 1D to it.
              else
                 message = message + t('d6system.no_cp_point', :name => char.name) + "%r"
              end
           end

          # fate roll
          if (self.fate_roll && (char == enactor))
             if (char.fate_points > 0)
                char.update(fate_points: char.fate_points - 1)
                message = message + t('d6system.spends_fate_point',
                  :name => (char == enactor) ? char.name : "#{self.name} (#{enactor.name})") + "%r"
             else
                message = message + t('d6system.no_fate_point', :name => char ? char.name : enactor.name) + "%r"
                self.fate_roll = false
             end
          else
             self.fate_roll = false
          end
        else
           if !D6System.valid_num_roll_str(self.roll_str)
              client.emit_failure t('d6system.numbers_only_for_npc_skills')
              return
           end  
        end
      
        if (self.difficulty == 0)
           roll_msg = D6System.emit_simple_roll(self.name, self.roll_str, enactor, self.fate_roll)
        else
           roll_msg = D6System.emit_difficulty_roll(self.name, self.roll_str, enactor, self.difficulty, self.fate_roll)
        end
        if !roll_msg
           client.emit_failure t('d6system.unknown_roll_params')
           return
        end
        message = message + roll_msg
        Achievements.award_achievement(enactor, "d6_roll")
        D6System.emit_results message, client, enactor_room, self.private_roll
      end
    end
  end
end      
