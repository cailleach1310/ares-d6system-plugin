module AresMUSH
  module D6System

    def self.init_specialization(char, spec, skill)
      D6Specialization.create(character: char, name: spec, skill: skill, rating: '0D+1')
    end

    # use this for setting attributes, skills and existing specializations
    def self.set_ability(char, name, rating)
      name = name.titleize
      if name =~ /\(/
        s_name = name.split("(")[0].rstrip
        s_skill = name.split("(")[1].gsub(")","")
      else
        s_name = name 
      end
      ability = D6System.find_ability(char, s_name)

      if (ability)
        ability.update(rating: rating)
      else
        ability_type = D6System.get_ability_type(s_name)
        case ability_type
        when :attribute
          ability = D6Attribute.create(character: char, name: name, rating: rating )
        when :skill
          ability = D6Skill.create(character: char, name: name, rating: rating )
        when :specialization
          ability = D6Specialization.create(character: char, name: s_name, skill: s_skill, rating: rating )
        end
      end
      return nil
    end

   # use this for advantages, disadvantages and special abilities
    def self.set_option(char, name, rank, details)
      name = name.titleize
      ability = D6System.find_ability(char, name)

      if (ability)
        ability.update(rank: rank)
        ability.update(details: details)
      else
        ability_type = D6System.get_ability_type(name)
        case ability_type
        when :advantage
          ability = D6Advantage.create(character: char, name: name, rank: rank, details: details )
        when :disadvantage
          ability = D6Disadvantage.create(character: char, name: name, rank: rank, details: details )
        when :special_ability
          ability = D6SpecialAbility.create(character: char, name: name, rank: rank, details: details )
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
    
    def self.valid_rank(option_name, rank)
       ability_type = D6System.get_ability_type(option_name)
       case ability_type
         when :advantage
           list = D6System.advantages
         when :disadvantage
           list = D6System.disadvantages
         when :special_ability
           list = D6System.special_abilities
       end
       option = list.find { |o| (o['name'] == option_name) }
       return option_ranks(option).include?(rank)
    end

    def self.reset_char(char)
      char.d6skills.each { |s| s.delete }
      char.d6attributes.each { |s| s.delete }
      char.d6specializations.each { |s| s.delete }
      char.d6advantages.each { |s| s.delete }
      char.d6disadvantages.each { |s| s.delete }
      char.d6specials.each { |s| s.delete }

      D6System.attr_names.each do |a|
        if !D6System.extranormal_attributes.include?(a)
           set_ability(char, a, '1D')
        else
           set_ability(char, a, '0D')
        end
      end
      D6System.skill_names.each do |a|
        set_ability(char, a, '0D+0')
      end

      starting_abilities = StartingAbilities.get_groups_for_char(char)
        
      starting_abilities.each do |k, v|
        set_starting_abilities(char, k, v)
      end

      starting_cp = Global.read_config("d6system","starting_char_points")
      starting_fate = Global.read_config("d6system","starting_fate_points")
      char.update(char_points: starting_cp)
      char.update(fate_points: starting_fate)
      char.update(wound_level: D6System.level_names[0])
    end

    def self.set_starting_abilities(char, group, ability_config)
      return if !ability_config  

      abilities = ability_config["abilities"]
      return if !abilities

      abilities.each do |k, v|
        D6System.set_ability(char, k, v)
      end
    end

    def self.get_max_value(ability_type)
      case ability_type
      when :skill, :specialization
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
        t("d6system.#{ability_type}_set", :name => ability.name, :rating => ability.rating)
      else
        t("d6system.ability_removed", :name => ability_name)
      end
    end

    def self.option_raised_text(char, ability_name)
      ability = D6System.find_ability(char, ability_name)
      ability_type = D6System.get_ability_type(ability_name)
      t("d6system.#{ability_type}_set", :name => ability.name, :rank => ability.rank)
    end

# creating an array of levels for advantages, disadvantages and special abilities
    def self.option_ranks(option)
       ranks = []
       if (option['ranks'].is_a? Integer)
          ranks << option['ranks']
       else
          option['ranks'].split("/").each do |rank|
             ranks << rank.to_i
          end
       end
       return ranks
    end

    def self.specials_cost(option)
      costs = []
      max = Global.read_config("d6system","max_rank_specials")
      first = option['cost']
      costs << first
      if Global.read_config("d6system","specials_difficult")
         for i in 1..(max-1) do
            costs << first
         end 
      else
         for i in 1..(max-1) do
            costs << 1
         end
      end
      return costs
    end

# Saving abilities from web chargen
    def self.save_abilities(char, chargen_data)
       save_ability_list(char, chargen_data[:custom][:attrs])
       save_ability_list(char, chargen_data[:custom][:skills])
       save_specializations(char, chargen_data[:custom][:specializations])
       save_option_list(char, chargen_data[:custom][:advantages])
       save_option_list(char, chargen_data[:custom][:disadvantages])
       save_option_list(char, chargen_data[:custom][:special_abilities])
    end

    def self.save_ability_list(char, list)
      alerts = []
      (list || {}).each do |a, b|
        error = set_ability(char, a, b)
        if (error)
          alerts << t('d6system.error_saving_ability', :name => a, :error => error)
        end
      end
     return alerts
    end

    def self.save_specializations(char, list)
      alerts = []
      (list || {}).each do |a, b|
        if (b != "0D+0")
           error = set_ability(char, a, b ) 
           if (error)
              alerts << t('d6system.error_saving_ability', :name => a, :error => error)
           end
        else
          name = a.split("(")[0].rstrip
          ability = find_ability(char, name)
          if (ability)
            ability.delete
          end
        end
      end
     return alerts
    end

    def self.save_option_list(char, list)
      alerts = []
      (list || {}).each do |a, b|
        rank = b.split(":")[0].to_i
        details = b.split(":")[1]
        if (rank > 0)
           error = set_option(char, a, rank, details )
           if (error)
              alerts << t('d6system.error_saving_ability', :name => a, :error => error)
           end
        else
          option = find_ability(char, a)
          if (option)
            option.delete
          end
        end
      end
     return alerts
    end

  end
end
