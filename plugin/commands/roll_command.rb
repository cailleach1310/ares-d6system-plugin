module AresMUSH
  module D6System
    class RollCmd
      include CommandHandler
      
      attr_accessor :name, :roll_str, :difficulty, :fate_roll, :cp_roll, :private_roll

      def parse_args
        if (cmd.args =~ /\//)
          args = cmd.parse_args(/(?<arg1>[^\/\=]+)\/(?<arg2>[^\=]+)\=?(?<arg3>.+)?/)  # arg1_slash_arg2_equals_optional_arg3        
          self.name = titlecase_arg(args.arg1)
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
        if self.roll_str.match(/^\d+[d|D]6?\+?\d?/)
           dice_result = D6System.parse_and_roll(enactor, self.roll_str)
        else
          char = Character.named(self.name)
          if (char)
             if self.cp_roll
                if (char.char_points > 0)
                   char.update(char_points: char.char_points - 1)
                   Achievements.award_achievement(char, "d6_cp_spent")
                   message = message + t('d6system.spends_char_point',
                    :name => char.name) + "%r"
                   self.roll_str = D6System.add_cp_die(self.roll_str)  # modify roll_str, add 1D to it.
                else
                   message = message + t('d6system.no_cp_point', :name => char.name) + "%r"
                end
             end
             dice_result = D6System.parse_and_roll(char, self.roll_str)
          else
             dice_result = nil
          end
        end
        
        if !dice_result
          client.emit_failure t('d6system.unknown_roll_params')
          return
        end
        
        if self.roll_str.match(/^\d+[d|D]6?\+?\d?/)
          overall_result = D6System.get_result(dice_result[:dice_roll]) + D6System.get_pips(self.roll_str)
           if (self.difficulty == 0)
              success_title = D6System.get_success_title(dice_result[:dice_roll])
              message = message + t('d6system.num_roll_result',
                :name => self.name ? "#{self.name} (#{enactor.name})" : enactor.name,
                :roll => self.roll_str,
                :dice => D6System.print_dice(dice_result[:dice_roll]),
                :total => overall_result,
                :success => success_title
              )
           else
              success_title = D6System.get_diff_success_title(overall_result - self.difficulty)
              message = message + t('d6system.difficulty_roll_result',
                :name => self.name ? "#{self.name} (#{enactor_name})" : self.name,
                :roll => self.roll_str,
                :dice => D6System.print_dice(dice_result[:dice_roll]),
                :details => self.roll_str,
                :total => overall_result,
                :diff_result => success_title,
                :difficulty => self.difficulty
              )
           end
        else
           overall_result = D6System.get_result(dice_result[:dice_roll]) + dice_result[:roll_modifiers]
           if self.fate_roll
             if (char.fate_points > 0)
                char.update(fate_points: char.fate_points - 1)
                message = message + t('d6system.spends_fate_point', 
                  :name => char ? char.name : "#{self.name} (#{enactor_name})") + "%r"
             else
                message = message + t('d6system.no_fate_point', :name => char ? char.name : enactor.name) + "%r"
                self.fate_roll = false
             end
           end

           if D6System.exceeds_roll_limit(char, self.roll_str)
              message = message + t('d6system.exceeds_roll_limit', 
                 :name => char ? char.name : enactor.name, 
                 :max => Global.read_config("d6system", "roll_max_dice") 
              ) + "%r"
           end 

           if (self.difficulty == 0)
              success_title = D6System.get_success_title(dice_result[:dice_roll])
              message = message + t('d6system.simple_roll_result', 
                :name => char ? char.name : "#{self.name} (#{enactor_name})",
                :roll => self.roll_str,
                :dice => D6System.print_dice(dice_result[:dice_roll]),
                :details => dice_result[:roll_details],
                :total => self.fate_roll ? overall_result.to_s + " --> " + (2 * overall_result).to_s  : overall_result,
                :success => success_title
              )         
          else
              overall_total = self.fate_roll ? overall_result * 2 : overall_result
              success_title = D6System.get_diff_success_title(overall_total - self.difficulty)
              message = message + t('d6system.difficulty_roll_result',
                :name => char ? char.name : "#{self.name} (#{enactor_name})",
                :roll => self.roll_str,
                :dice => D6System.print_dice(dice_result[:dice_roll]),
                :details => dice_result[:roll_details],
                :total => overall_total,
                :diff_result => success_title,
                :difficulty => self.difficulty
              )
          end

        end
        Achievements.award_achievement(enactor, "d6_roll")
        D6System.emit_results message, client, enactor_room, self.private_roll
      end
    end
  end
end      
