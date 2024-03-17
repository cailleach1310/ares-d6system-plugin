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
          if (ability_type == :skill)
            linked_attr = D6System.get_linked_attr(self.name)
            ability_rating = D6System.ability_rating(enactor, linked_attr)
          else
            client.emit_failure "No such ability: " + self.name
            return
          end
        else  
          ability_rating = ability.rating
        end
        new_rating = D6System.change_ability(ability_rating, cmd.root)
        dice = D6System.get_dice(new_rating)
        pips = D6System.get_pips(new_rating)
        error = D6System.check_dice(enactor, self.name, dice, pips)
        if (error)
          client.emit_failure error
          return
        end
        rating = dice.to_s + 'D'
        rating = (pips > 0) ? rating + '+' + pips.to_s : rating
        if (((ability_type == :specialization) || (ability_type == :skill)) && (rating == D6System.linked_rating(enactor, self.name)) ) 
          ability.delete
        else          
          error = D6System.set_ability(enactor, self.name, rating)
          if (error)
            client.emit_failure error
          end
        end
        if (ability_type == :attribute)    # When raising or lowering attributes, make sure to adjust related skills and specializations
          # adjust all learned skills 
          related_skills = D6System.skill_list(enactor, self.name, false)
          related_skills.each do |skill|
             client.emit "Adjusting " + skill['name']
             new_rating = D6System.change_ability(skill['rating'], cmd.root)
             D6System.set_ability(enactor, skill['name'], new_rating)
          end
          # adjust specializations of all linked skills (not just those that have been learned)
          linked_skills = D6System.skills.select { |s| (s['linked_attr'] == self.name) }.map { |skill| skill['name'] }
          linked_skills.each do |skill|
             related_specs = D6System.related_specs(enactor, skill)
             related_specs.each do |spec|
                client.emit "Adjusting " + spec.name
                new_rating = D6System.change_ability(spec.rating, cmd.root)
                D6System.set_ability(enactor, spec.name, new_rating)
             end
          end
        else
          if (ability_type == :skill)    # When raising or lowering skills, make sure to adjust related specializations
             # adjust linked specializations
             related_specs = D6System.related_specs(enactor, self.name)
             related_specs.each do |spec|
                client.emit "Adjusting " + spec.name
                new_rating = D6System.change_ability(spec.rating, cmd.root)
                D6System.set_ability(enactor, spec.name, new_rating)
             end
          end
        end
        client.emit_success D6System.ability_raised_text(enactor, self.name)
      end
    end
  end
end
