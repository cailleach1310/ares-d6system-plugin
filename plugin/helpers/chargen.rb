module AresMUSH
  module D6System

    def self.spent_points(char)
      sum = 0
      return sum
    end

    def self.skill_list(char, attr, chargen)
      abilities = []
      list = D6System.skills
      list.each do |m|
         if (m['linked_attr'] == attr)
            dice_str = D6System.ability_rating(char, m['name'])
            if (chargen)
               abilities << { 'name' => m['name'], 'dice' => dice_str, 'desc' => m['desc'] }
            else
               abilities << { 'name' => m['name'], 'dice' => dice_str }
            end
         end
      end
      return abilities.sort_by { |a| a['name'] }
#      attribute_info = { 'name' => attr, 'dice' => D6System.ability_rating(char, attr) }
#      return 
#         { 'attribute' => attribute_info,
#           'skills' => abilities.sort_by { |a| a['name'] } }
    end

    def self.init_abilities(char)
      D6System.attr_names.each do |a|
        if !D6System.extranormal_attributes.include?(a)
           D6Attribute.create(character: char, name: a, dice: 1, pips: 0 )
        else
           D6Attribute.create(character: char, name: a, dice: 0, pips: 0 )
        end
      end
      D6System.skill_names.each do |a|
        D6Skill.create(character: char, name: a, dice: 0, pips: 0 )
      end
    end

    # use this for setting attributes and skills
    def self.set_ability(char, name, dice, pips)
      name = name.titleize
      ability = D6System.find_ability(char, name)

      if (ability)
        ability.update(dice: dice)
        ability.update(pips: pips)
      else
        ability_type = D6System.get_ability_type(name)
        case ability_type
        when "attribute"
          ability = D6Attribute.create(character: char, name: name, dice: dice, pips: pips )
        when "skill"
          ability = D6Skill.create(character: char, name: name, dice: dice, pips: pips )
        end
      end
      return nil
    end

   # use this for advantages and disadvantages
    def self.set_advantage(char, name, rating)
      name = name.titleize
      ability = D6System.find_ability(char, name)

      if (ability)
        ability.update(rating: rating)
      else
        ability_type = D6System.get_ability_type(name)
        case ability_type
        when "advantage"        
          ability = D6Advantage.create(character: char, name: name, rating: rating )
        when "disadvantage"
          ability = D6Disadvantage.create(character: char, name: name, rating: rating )
        end
      end
      return nil
    end


    def self.check_dice(ability_name, dice, pips)
      # extranormal being the exception for both attributes and skills
      return nil if (D6System.extranormal_attributes.include?(ability_name) || D6System.extranormal_attributes.include?(D6System.get_linked_attr(ability_name)))  
      ability_type = D6System.get_ability_type(ability_name)
      min_dice = D6System.get_min_value(ability_type)
      max_dice = D6System.get_max_value(ability_type)

      return t('d6system.max_dice_is', :name => ability_name, :max => max_dice) if (dice > max_dice)
      return t('d6system.max_dice_is', :name => ability_name, :max => max_dice) if ((dice == max_dice) && (pips > 0))
      return t('d6system.min_dice_is', :name => ability_name, :min => min_dice) if (dice < min_dice)
      return nil
    end
    
    def self.reset_char(char)
      char.d6skills.each { |s| s.delete }
      char.d6attributes.each { |s| s.delete }
      char.d6advantages.each { |s| s.delete }
      char.d6disadvantages.each { |s| s.delete }

      D6System.init_abilities(char)        
    end

    def self.get_max_value(ability_type)
      case ability_type
      when :skill
        return Global.read_config("d6system", "max_skill_dice")
      when :attribute
        return Global.read_config("d6system", "max_attr_dice")
      when :advantage, :disadvantage
        return Global.read_config("d6system", "max_advantage_rating")
      else
        return 0
      end
    end

    def self.get_min_value(ability_type)
      case ability_type
      when :skill
        return Global.read_config("d6system", "min_skill_dice")
      when :attribute
        return Global.read_config("d6system", "min_attr_dice")
      else
        return 0
      end
    end

    def self.ability_raised_text(char, ability_name)
      ability = D6System.find_ability(char, ability_name)
      if (ability)
        ability_type = D6System.get_ability_type(ability_name)
        t("d6system.#{ability_type}_set", :name => ability.name, :dice => ability.dice, :pips => ability.pips)
      else
        t("d6system.ability_removed", :name => ability_name)
      end
    end

# Saving abilities from web chargen
    def self.save_abilities(char, chargen_data)
       save_ability_list(char, chargen_data[:custom][:attrs])
       save_ability_list(char, chargen_data[:custom][:skills])
       save_advantage_list(char, chargen_data[:custom][:advantages])
#       save_advantage_list(char, chargen_data[:custom][:disadvantages])
    end

    def self.save_ability_list(char, list)
      alerts = []
      (list || {}).each do |a, b|
        dice = b.split("D")[0].to_i
        pips = b.split("+")[1].to_i
        error = set_ability(char, a, dice, pips )
        if (error)
          alerts << t('d6system.error_saving_ability', :name => a, :error => error)
        end
      end
     return alerts
    end

    def self.save_advantage_list(char, list)
      alerts = []
      (list || {}).each do |a, b|
        if (b.to_i > 0)
           error = set_advantage(char, a, b.to_i ) 
           if (error)
              alerts << t('d6system.error_saving_ability', :name => a, :error => error)
           end
        end
      end
     return alerts
    end

  end
end
