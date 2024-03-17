module AresMUSH
  module D6System

    def self.migrate_all()
       Global.logger.info "Starting migration of characters to new D6System combined ratings."
       Character.all.each do |c|
         if !is_migrated(c.name)
            char_migration_message = migrate_char(c.name)
            Global.logger.info char_migration_message
        else
          Global.logger.info "Skipping #{c.name}, already migrated."
        end
      end 
    end

    def self.test_migration(char_name)
       summary = "Listing skills:%r"
       char = Character.named(char_name)
       return "Character not found." if !char
       char.d6skills.each do |skill|
          summary = summary + "%r * #{skill.name}: #{skill.rating}"
       end
       char.d6specializations.each do |skill|
          summary = summary + "%r * #{skill.name}: #{skill.rating}"
       end
       return summary
    end

    def self.is_migrated(char_name)
       char = Character.named(char_name)
       return nil if !char
       char.d6skills.each do |skill|
          if (skill.rating == "0D+0")
             return false
          end
       end
       char.d6specializations.each do |spec|
          spec_rating = ability_rating(char, spec.name)
          skill_rating = ability_rating(char, spec.skill)
          if skill_rating >= spec_rating
             return false
          end  
       end
       return true
    end

    def self.migrate_char(char_name)
       summary = "%rProcessing migrations for #{char_name}:"
       char = Character.named(char_name)
       return "Character not found." if !char

       summary = summary + "%r%rSKILLS"
       char.d6skills.each do |skill|
          if (skill.rating != "0D+0")
             update_rating = get_combined_rating(char, skill.name)
             summary = summary + "%r * #{skill.name}: #{skill.rating} --> #{update_rating}"
             D6System.set_ability(char, skill.name, update_rating)
          end
       end

       summary = summary + "%r%rSPECIALIZATIONS"
       char.d6specializations.each do |spec|
          update_rating = get_combined_rating(char, spec.name)
          summary = summary + "%r * #{spec.name}: #{spec.rating} --> #{update_rating}"
          D6System.set_ability(char, spec.name, update_rating)
       end

       summary = summary + "%r%rCleaning up untrained skills...%r"
       char.d6skills.each do |skill|
          if (skill.rating == "0D+0")
            summary = summary + "#{skill.name} "
            skill.delete
          end
       end
       
       summary = summary + "%r%r#{char_name} migrated successfully!"
       return summary
    end

    def self.get_combined_rating(char, ability_name)
      ability_type = D6System.get_ability_type(ability_name)
      ability = D6System.find_ability(char, ability_name)
      if (ability)
         rating = D6System.ability_rating(char, ability_name)
         if (ability_type == :specialization)
            ability = D6System.find_ability(char, ability_name)
            spec_rating = D6System.ability_rating(char, ability.skill)
            if (spec_rating != '0D+0') 
              rating = D6System.add_dice(rating, spec_rating,0)
            else
              attr_rating = D6System.ability_rating(char, D6System.get_linked_attr(ability.skill))
              rating = D6System.add_dice(rating, attr_rating,0)
            end
         elsif (ability_type == :skill)
            attr_rating = D6System.ability_rating(char, D6System.get_linked_attr(ability_name))
            rating = D6System.add_dice(rating, attr_rating,0)
         end
         return rating
      end
    end

  end
end
