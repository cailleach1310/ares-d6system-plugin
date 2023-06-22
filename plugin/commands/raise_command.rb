module AresMUSH
  module D6System
    class RaiseCmd
      include CommandHandler
      
      attr_accessor :name

      def parse_args
        self.name = titlecase_arg(cmd.args)
      end

      def required_args
        [ self.name ]
      end
      
      def check_chargen_locked
        Chargen.check_chargen_locked(enactor)
      end
      
      def handle
        ability_type = D6System.get_ability_type(self.name)

        case ability_type
          when "advantage"
            client_emit "Please use the commands advantage/raise and advantage/lower instead."
            return
          when "disadvantage"
            client_emit "Please use the commands disadvantage/raise and disadvantage/lower instead."
            return
         end

        ability = D6System.find_ability(enactor, self.name)

        if cmd.root_is?("raise")
          if (ability.pips == 2)
             new_dice = ability.dice + 1
             new_pips = 0
          else
             new_pips = ability.pips + 1
             new_dice = ability.dice
          end
        else
          if (ability.pips == 0)
             new_dice = ability.dice - 1
             new_pips = 2
          else
             new_pips = ability.pips - 1
             new_dice = ability.dice
          end
        end        
        error = D6System.check_dice(self.name, new_dice, new_pips)
        if (error)
          client.emit_failure error
          return
        end
      
        error = D6System.set_ability(enactor, self.name, new_dice, new_pips)
        if (error)
          client.emit_failure error
        else
          client.emit_success D6System.ability_raised_text(enactor, self.name)
        end
      end
    end
  end
end
