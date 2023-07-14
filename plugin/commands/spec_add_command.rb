module AresMUSH
  module D6System
    class SpecAddCmd
      include CommandHandler
      
      attr_accessor :name, :skill

      def parse_args
        if cmd.args =~ /\=/
          args = cmd.parse_args(ArgParser.arg1_equals_arg2)
          self.name = titlecase_arg(args.arg1)
          self.skill = titlecase_arg(args.arg2)
        else
          self.name = titlecase_arg(cmd.args)
          self.skill = nil
        end
      end

      def required_args
        [ self.name ]
      end
      
      def check_chargen_locked
        Chargen.check_chargen_locked(enactor)
      end
      
      def handle
        ability = D6System.find_ability(enactor, self.name)

        if (cmd.switch == 'add') 
          if (ability == nil)
             if (!self.skill)
                client.emit_failure "You need to specify a skill!"
             elsif (D6System.get_ability_type(self.skill) != :skill)
                client.emit_failure "You need to specify a valid skill!"
             else
                D6System.init_specialization(enactor, self.name, self.skill)
                client.emit_success t('d6system.specialization_added', :name => self.name, :skill => self.skill)
             end
          else
            client.emit_failure "You already have that specialization! Use 'raise' and 'lower' commands to change the rating."
          end
       else 
         if (cmd.switch == 'remove')
            if (ability == nil)
               client.emit_failure "You don't have that specialization!"
            elsif (D6System.get_ability_type(self.name) != :specialization)
               client.emit_failure "That is not a specialization!"
            else
               ability.delete
               client.emit_success t('d6system.ability_removed', :name => self.name)
            end 
         end
       end
     end

    end
  end
end
