module AresMUSH
  module D6System
    class CpAddSpecCmd
      include CommandHandler
      
      attr_accessor :name, :spec, :skill, :cp_raise

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_slash_arg2_equals_arg3)
        self.name = titlecase_arg(args.arg1)
        self.spec = titlecase_arg(args.arg2)
        self.skill = titlecase_arg(args.arg3)
      end

      def required_args
        [ self.name, self.spec, self.skill ]
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

        if (D6System.get_ability_type(self.skill) != :skill)
          client.emit_failure self.skill + " isn't a valid skill."
          return
        end

        if D6System.find_ability(char, self.spec)
            client.emit_failure self.name + " already has specialization " + self.spec + ". Please use cp/raise command to raise this specialty." 
            return
        end

        raise_cost = D6System.get_initial_cost(char, self.skill)
        error = D6System.init_with_cp(char, self.spec, self.skill)
        if error
           client.emit_failure error
        else 
           rating = D6System.ability_rating(char, self.spec)
           message = t("d6system.cp_ability_raised", :enactor => enactor.name, :name => self.name, :ability => self.spec, 
                :rating => rating, :cost => raise_cost)
           client.emit_success message
           Login.emit_if_logged_in char, message
           Login.notify(char, :achievement, message, char.id)
        end
      end
    end
  end
end
