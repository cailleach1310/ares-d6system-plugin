module AresMUSH
  module D6System
    class CpRaiseCmd
      include CommandHandler
      
      attr_accessor :name, :ability, :cp_raise

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2)
        self.name = titlecase_arg(args.arg1)
        self.ability = titlecase_arg(args.arg2)
      end

      def required_args
        [ self.name, self.ability ]
      end
      
      def handle

        if !(enactor.is_admin?)
           client.emit_failure "You're not allowed to do that.\n"
           return
        end

        char = Character.find_one_by_name self.name
        if !(char)
           client.emit_failure "Character " + self.name + " doesn't exist."
           return
        end

        if !(char.is_approved?)
           client.emit_failure "Character " + self.name + " hasn't been approved yet."
           return
        end

        ability_type = D6System.get_ability_type(self.ability)
        case ability_type
          when :advantage, :disadvantage, :special_ability
            client.emit "You'll need to change this with the chargen option on the webportal."
            return
         end

        if ((ability_type == :specialization) && !D6System.find_ability(char, self.ability))
            client.emit_failure "Invalid ability for " + self.name + ": " + self.ability
            return
        end

        raise_cost = D6System.get_raise_cost(char, self.ability)

        error = D6System.raise_with_cp(char, self.ability)
        if (error)
           client.emit_failure error
           return
        else
           rating = D6System.ability_rating(char, self.ability)
           message = t("d6system.cp_ability_raised", :enactor => enactor.name, :name => char.name, :ability => self.ability,
                :rating => rating, :cost => raise_cost)
           message = message + "%rThe following abilities have been adjusted: " + D6System.get_related_list(char, self.ability).join(", ")
           client.emit_success message
           Login.emit_if_logged_in char, message
           Login.notify(char, :achievement, message, char.id)  # cheating here a little, just to have that eye in the webportal view linking to the char page
        end
      end
    end
  end
end
