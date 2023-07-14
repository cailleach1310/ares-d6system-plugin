module AresMUSH
  module D6System
    class AbilitySetCmd
      include CommandHandler
      
      attr_accessor :name, :dice, :pips

      def parse_args
        args = cmd.parse_args(/(?<name>[^\=]+?)\=(?<dice>\d+)[D|d]6?\+?(?<pips>\d)?/)
        self.name = titlecase_arg(args.name)
        self.dice = integer_arg(args.dice)
        self.pips = integer_arg(args.pips) ? integer_arg(args.pips) : 0  
      end

      def required_args
        [ self.name, self.dice ]
      end
      
      def check_chargen_locked
        Chargen.check_chargen_locked(enactor)
      end
      
      def handle
        ability_type = D6System.get_ability_type(self.name)

        case ability_type
          when "advantage"
            client_emit "Please use the command advantage/set."
            return
          when "disadvantage"
            client_emit "Please use the commands disadvantage/set."
            return
        end

        if (self.pips > 2)
           client.emit_failure "Pips parameter is greater than 2."
           return
        end

        error = D6System.check_dice(self.name, self.dice, self.pips)
        if (error)
          client.emit_failure error
          return
        end
        rating = self.dice.to_s + 'D+' + self.pips.to_s 
        D6System.set_ability(enactor, self.name, rating)
        client.emit_success D6System.ability_raised_text(enactor, self.name)
      end

    end
  end
end
