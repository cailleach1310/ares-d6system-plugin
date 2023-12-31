module AresMUSH
  module D6System
    class OptionSetCmd
      include CommandHandler
      
      attr_accessor :name, :rank, :details

      def parse_args
        if cmd.args =~ ArgParser.arg1_equals_arg2_slash_arg3   # case 1: name=rank/details, regexp needs to be added here
           args = cmd.parse_args(ArgParser.arg1_equals_arg2_slash_arg3)
           self.name = titlecase_arg(args.arg1)
           self.rank = args.arg2 ? integer_arg(args.arg2) : 1
           self.details = args.arg3
        elsif cmd.args =~ /\=/ # case 2: special=rank (special ability)
           args = cmd.parse_args(ArgParser.arg1_equals_arg2)
           self.name = titlecase_arg(args.arg1)
           self.rank = integer_arg(args.arg2)
           ability_type = D6System.get_ability_type(self.name)
           self.details = (ability_type == :special_ability) ? D6System.special_abilities.find { |a| a['name'] == self.name }['desc'] : nil
        else # case 3: spec (assuming R1)
           self.name = titlecase_arg(cmd.args)
           ability_type = D6System.get_ability_type(self.name)
           self.details = (ability_type == :special_ability) ? D6System.special_abilities.find { |a| a['name'] == self.name }['desc'] : nil
           self.rank = (ability_type == :special_ability) ? 1 : 0
        end
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
          when :attribute, :skill
            client.emit "Please use the command 'ability/set' for attributes and skills."
            return
          when :specialization
            client.emit "Please use the command 'spec/add' for specializations."
            return
        end
   
        if (cmd.switch == "set") || (cmd.switch == "add")
           if !(self.details) && (ability_type != :special_ability)
               client.emit "You need to specify details for the option. See 'help d6options'."
               return
           end
           if (ability_type != :special_ability) && !D6System.valid_rank(self.name, self.rank)
               client.emit "You need to specify a valid rank for the option. See 'help d6options'."
               return
           end    
           D6System.set_option(enactor, self.name, self.rank, self.details)
           client.emit_success D6System.option_raised_text(enactor, self.name)
        elsif (cmd.switch == "remove")
           option = D6System.find_ability(enactor, self.name)
           if (option)
               option.delete
               client.emit_success D6System.ability_raised_text(enactor, self.name)
           else
               client.emit_failure "You don't have that option set."    
           end
         end
      end

    end
  end
end
