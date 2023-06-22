module AresMUSH
  module D6System
    class RollCmd
      include CommandHandler
      
      attr_accessor :name, :roll_str, :difficulty, :fate_roll, :private_roll

      def parse_args
        if (cmd.args =~ /\//)
          args = cmd.parse_args(/(?<arg1>[^\/]+)\/(?<arg2>[^\/]+)\=?(?<arg3>.+)?/)  # arg1_slash_arg2_equals_optional_arg3        
          self.name = titlecase_arg(args.arg1)
          self.roll_str = titlecase_arg(args.arg2)
          self.difficulty = args.arg3 ? args.arg3 : nil
        else
          args = cmd.parse_args(ArgParser.arg1_equals_optional_arg2)
          self.name = enactor.name        
          self.roll_str = titlecase_arg(args.arg1)
          self.difficulty = args.arg2 ? args.arg2 : nil
        end
        self.private_roll = cmd.switch_is?("private")
        self.fate_roll = cmd.switch_is?("fate")
      end
      
      def required_args
        [ self.name, self.roll_str ]
      end
      
      def handle
        message = ""
        if self.roll_str.match(/^\d+[d|D]6?\+?\d?/)
           dice_result = D6System.parse_and_roll(enactor, self.roll_str)
        else
          char = Character.named(self.name)
          if (char)
             dice_result = D6System.parse_and_roll(char, self.roll_str)
          else
             dice_result = nil
          end
        end
        
        if !dice_result
          client.emit_failure t('d6system.unknown_roll_params')
          return
        end
        
        if self.fate_roll
          # check fate points and lower them by one.
          Achievements.award_achievement(enactor, "d6_fate_spent")
        end  

        success_title = D6System.get_success_title(dice_result[:dice_roll])

        if self.roll_str.match(/^\d+[d|D]6?\+?\d?/)
          overall_result = D6System.get_result(dice_result[:dice_roll]) + D6System.get_pips(self.roll_str)
          message = message + t('d6system.num_roll_result',
          :name => enactor.name,
          :roll => self.roll_str,
          :dice => D6System.print_dice(dice_result[:dice_roll]),
          :total => overall_result,
          :success => success_title
        )
        else
           overall_result = D6System.get_result(dice_result[:dice_roll]) + dice_result[:roll_modifiers]
           if self.fate_roll
              message = message + t('d6system.spends_fate_point', 
                :name => char ? char.name : "#{self.name} (#{enactor_name})") + "%r"
              overall_result = overall_result.to_s + " --> " + (2 * overall_result).to_s
           end

           message = message + t('d6system.simple_roll_result', 
             :name => char ? char.name : "#{self.name} (#{enactor_name})",
             :roll => self.roll_str,
             :dice => D6System.print_dice(dice_result[:dice_roll]),
             :details => dice_result[:roll_details],
             :total => overall_result,
             :success => success_title
           )
        end
        Achievements.award_achievement(enactor, "d6_roll")
        D6System.emit_results message, client, enactor_room, self.private_roll
      end
    end
  end
end      
