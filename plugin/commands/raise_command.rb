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
          when :advantage, :disadvantage, :special_ability
            client.emit "Please use the commands option/add and option/remove."
            return
         end

        ability = D6System.find_ability(enactor, self.name)
        if (!ability)
          client.emit_failure "No such ability: " + self.name
        else  
          dice = D6System.get_dice(ability.rating)
          pips = D6System.get_pips(ability.rating)

          if cmd.root_is?("raise")
            if (pips == 2)
             new_dice = dice + 1
             new_pips = 0
            else
               new_pips = pips + 1
               new_dice = dice
            end
          elsif cmd.root_is?("lower")
            if (pips == 0)
               new_dice = dice - 1
               new_pips = 2
            else
               new_pips = pips - 1
               new_dice = dice
            end
          end        
          error = D6System.check_dice(self.name, new_dice, new_pips)
          if (error)
            client.emit_failure error
            return
          end
          rating = new_dice.to_s + 'D+' + new_pips.to_s
          if ((ability_type == :specialization) && (rating == "0D+0"))
            ability.delete
            client.emit_success D6System.ability_raised_text(enactor, self.name)
          else
            error = D6System.set_ability(enactor, self.name, rating)
            if (error)
              client.emit_failure error
            else
              client.emit_success D6System.ability_raised_text(enactor, self.name)
            end
          end
        end
      end
    end
  end
end
