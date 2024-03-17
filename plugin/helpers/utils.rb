module AresMUSH
  module D6System

    def self.attributes
      Global.read_config("d6system", "attributes")
    end

    def self.skills
      Global.read_config("d6system", "skills")
    end

    def self.advantages
      Global.read_config("d6system", "advantages")
    end

    def self.disadvantages
      Global.read_config("d6system", "disadvantages")
    end

    def self.special_abilities
      Global.read_config("d6system", "special_abilities")
    end

    def self.attributes_blurb
      Global.read_config("d6system", "attributes_blurb")
    end

    def self.skills_blurb
      Global.read_config("d6system", "skills_blurb")
    end

    def self.specializations_blurb
      Global.read_config("d6system", "specializations_blurb")
    end

    def self.extranormal_blurb
      Global.read_config("d6system", "extranormal_blurb")
    end

    def self.advantages_blurb
      Global.read_config("d6system", "advantages_blurb")
    end

    def self.disadvantages_blurb
      Global.read_config("d6system", "disadvantages_blurb")
    end

    def self.specials_blurb
      Global.read_config("d6system", "specials_blurb")
    end

    def self.extranormal_attributes
      Global.read_config("d6system", "extranormal_attributes")
    end

    def self.sheet_columns
      Global.read_config("d6system", "sheet_columns")
    end

    def self.can_view_sheets?(actor)
      return true if Global.read_config("d6system", "show_sheet")
      return false if !actor
      actor.has_permission?("view_sheets")
    end

    def self.spec_pretty(spec)
      spec_str = spec.name + " (" + spec.skill + ")"
      return spec_str
    end

    def self.get_linked_attr(skill_name)
       skill = D6System.skills.find { |s| (s['name'] == skill_name) }
       if !(skill)
          return nil
       else
          return skill['linked_attr']
       end
    end

    def self.calculate_strength_damage(char)
       physique_rating = ability_rating(char,"Physique")
       lifting_rating = ability_rating(char,"Lifting")
       str_dmg = ([ D6System.get_dice(physique_rating), D6System.get_dice(D6System.add_dice(physique_rating, lifting_rating, 0))].max/2.to_f).ceil
    end

    def self.other_stats(char)
      list = []
      list << { 'name' => 'Fate Points', 'rating' => char.fate_points }
      list << { 'name' => 'Char Points', 'rating' => char.char_points }
      list << { 'name' => 'Strength Damage', 'rating' => calculate_strength_damage(char).to_s + "D" }
      list << { 'name' => 'Wound Level', 'rating' => char.wound_level }
      return list
    end

    def self.attr_names
       D6System.attributes.map { |a| a['name'].titlecase }
    end

    def self.skill_names
       D6System.skills.map { |a| a['name'].titlecase }
    end

    def self.advantage_names
       D6System.advantages.map { |a| a['name'].titlecase }
    end

    def self.disadvantage_names
       D6System.disadvantages.map { |a| a['name'].titlecase }
    end

    def self.special_ability_names
       D6System.special_abilities.map { |a| a['name'].titlecase }
    end

    def self.find_ability(char, ability_name)
      return nil if !ability_name
      ability_name = ability_name.titlecase
      ability_type = get_ability_type(ability_name)
      case ability_type
      when :attribute
        char.d6attributes.find(name: ability_name).first
      when :skill
        char.d6skills.find(name: ability_name).first
      when :specialization
        char.d6specializations.find(name: ability_name).first
      when :advantage
        char.d6advantages.find(name: ability_name).first
      when :disadvantage
        char.d6disadvantages.find(name: ability_name).first
      when :special_ability
        char.d6specials.find(name: ability_name).first
      else
        nil
      end
    end

    def self.get_ability_type(ability)
      ability = ability.titlecase
      if attr_names.include?(ability)
        return :attribute
      elsif skill_names.include?(ability)
        return :skill
      elsif advantage_names.include?(ability)
        return :advantage
      elsif disadvantage_names.include?(ability)
        return :disadvantage
      elsif special_ability_names.include?(ability)
        return :special_ability
      else
        return :specialization
      end
    end

    def self.skill_list(char, attr, chargen)
      abilities = []
      list = D6System.skills
      list.each do |m|
         if (m['linked_attr'] == attr)
            dice_str = D6System.ability_rating(char, m['name'])
            if (chargen)
               abilities << { 'name' => m['name'], 'rating' => dice_str, 'desc' => m['desc'], 'linked_attr' => attr }
            else
               if ((D6System.get_dice(dice_str) > 0) || (D6System.get_pips(dice_str) > 0))
                  abilities << { 'name' => m['name'], 'rating' => dice_str }
               end
            end
         end
      end
      return abilities.sort_by { |a| a['name'] }
    end

    def self.change_ability(rating, mode)
      dice = D6System.get_dice(rating)
      pips = D6System.get_pips(rating)
 
     if (mode == "raise")
       if (pips == 2)
         new_dice = dice + 1
         new_pips = 0
       else
         new_pips = pips + 1
         new_dice = dice
       end
     elsif (mode == "lower")
       if (pips == 0)
          new_dice = dice - 1
          new_pips = 2
       else
          new_pips = pips - 1
          new_dice = dice
       end
     end
     return new_dice.to_s + 'D+' + new_pips.to_s       
    end

  end
end
