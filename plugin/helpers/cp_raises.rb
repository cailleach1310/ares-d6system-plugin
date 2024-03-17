module AresMUSH
  module D6System

    def self.can_view_cp?(actor, target)
      return false if !actor
      return true if target == actor
      return true if actor.is_admin?
      AresCentral.is_alt?(actor, target)
    end

    def self.get_raise_cost(char, ability_name)
      type = D6System.get_ability_type(ability_name)
      rating = D6System.ability_rating(char, ability_name)
      linked_rating = D6System.linked_rating(char, ability_name)
      dice = (rating != "0D") ? D6System.get_dice(rating) : D6System.get_dice(linked_rating)
      Global.logger.debug "Ability: #{ability_name}, Rating: #{rating}, Linked Rating: #{linked_rating}, Dice: #{dice}"
      if (type == :skill)
         return dice
      elsif (type == :specialization)
         return (dice/2.to_f).ceil
      elsif (type == :attribute)
         return dice * 10
      else
          return 0
      end
    end

    def self.get_initial_cost(char, skill)
      rating = D6System.ability_rating(char, skill)
      linked_rating = D6System.linked_rating(char, skill)
      dice = (rating != "0D") ? D6System.get_dice(rating) : D6System.get_dice(linked_rating)
      Global.logger.debug "Skill: #{skill}, Rating: #{rating}, Linked Rating: #{linked_rating}, Dice: #{dice}"
      return (dice/2.to_f).ceil
    end

    def self.init_with_cp(char, specialization, skill)
      cost = get_initial_cost(char, skill)
      if (char.char_points >= cost)
         D6System.init_specialization(char, specialization, skill)
         char.update(char_points: char.char_points - cost)
      else
         return t("d6system.not_enough_cp", :name => char.name, :ability => specialization, :cost => cost, :points => char.char_points)
      end
      return nil
    end

    def self.raise_with_cp(char, ability_name)
      cost = get_raise_cost(char, ability_name)
      if (char.char_points >= cost)
         error = raise_ability(char, ability_name, "raise")
         return error if error
         char.update(char_points: char.char_points - cost)
      else
         return t("d6system.not_enough_cp", :name => char.name, :ability => ability_name, :cost => cost, :points => char.char_points)
      end
      return nil
    end

    def self.raise_ability(char, ability_name, mode)
      ability = D6System.find_ability(char, ability_name)
      if ability
         rating = D6System.change_ability(ability.rating, mode)
      else
         if (D6System.get_ability_type(ability_name) == :skill)
            linked_rating = D6System.linked_rating(char, ability_name)
            rating = D6System.change_ability(linked_rating, mode)
         else
            return "No such ability: " + ability_name
         end
      end
      error = D6System.set_ability(char, ability_name, rating)
      if error
         return error
      end
      related_abilities = get_related_list(char, ability_name)
      related_abilities.each do |a|
         new_rating = D6System.change_ability(D6System.ability_rating(char, a), mode)
         D6System.set_ability(char, a, new_rating)
      end
      return
    end

    def self.get_related_list(char, ability_name)    # get list of affected abilities, return only the names of those
      type = D6System.get_ability_type(ability_name)
      list = []
      if (type == :skill)
        related_specs = D6System.related_specs(char, ability_name)
        related_specs.each do |spec|
           list << spec.name
        end
      elsif (type == :attribute)
        related_skills = D6System.skill_list(char, ability_name, false)
        related_skills.each do |skill|
           list << skill['name']
        end
        linked_skills = D6System.skills.select { |s| (s['linked_attr'] == ability_name) }.map { |skill| skill['name'] }
        linked_skills.each do |skill|
           related_specs = D6System.related_specs(char, skill)
           related_specs.each do |spec|
              list << spec.name
           end
        end
      end
      return list
    end

    def self.related_specs(char, skill_name)
      return char.d6specializations.select { |spec| ( spec.skill == skill_name ) }
    end

      def self.test_cp_list(char_name)
        list = D6System.skill_names
        Character.all.select{ |c| c.name == char_name}.map { |c|
        list.to_a.sort_by { |a| a }.map { |a| {
          name: a.titlecase,
          rating: D6System.ability_rating(c, name),
#          can_raise: !D6System.check_can_learn(c, name, rating),
          cost: get_raise_cost(c, name)
#          cp_needed: a.cp_needed
        }} }
      end

  end
end
