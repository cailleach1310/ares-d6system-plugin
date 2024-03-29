module AresMUSH
  module D6System
    
    def self.dice_to_roll_for_ability(char, roll_params)
      ability = roll_params.ability
      ability_type = D6System.get_ability_type(ability)
      skill_rating = D6System.ability_rating(char, ability)
      apt_rating = "0D+0"
      if (ability_type == :specialization)
        spec = find_ability(char, ability)
        skill = spec.skill
      else
        skill = ability 
      end
      if roll_params.linked_attr
         linked_attr = D6System.get_linked_attr(skill)
         if (linked_attr != roll_params.linked_attr)
            skill_rating = sub_dice(skill_rating, D6System.ability_rating(char, linked_attr))   # remove linked_attr dice from the rating
            apt_rating = D6System.ability_rating(char, roll_params.linked_attr)                 # add attribute speficied in the roll 
         end 
      end
      
      max_dice = Global.read_config("d6system", "roll_max_dice")
      rating = add_dice(skill_rating, apt_rating, 0)
      dice = ( max_dice == {} ) || !dice_gt_max(rating, max_dice) ? add_dice(skill_rating, apt_rating, roll_params.dice) : add_dice(max_dice, "0D+0", roll_params.dice)
      Global.logger.debug "#{char.name} rolling #{ability} dice=#{roll_params.dice} pips=#{roll_params.pips} skill=#{skill_rating} linked_attr=#{linked_attr} apt=#{apt_rating}"
      
      dice
    end

    def self.add_dice(dice1, dice2, modifier)
       dice_sum = dice1.split("D")[0].to_i + dice2.split("D")[0].to_i
       pips_sum = dice1.split("+")[1].to_i + dice2.split("+")[1].to_i
       dice_sum = dice_sum + pips_sum / 3 + modifier
       return dice_sum.to_s + "D+" + (pips_sum % 3).to_s
    end

    def self.sub_dice(dice1, dice2)
       dice_diff = dice1.split("D")[0].to_i - dice2.split("D")[0].to_i
       pips_diff = dice1.split("+")[1].to_i - dice2.split("+")[1].to_i
       dice_diff = (pips_diff < 0) ? dice_diff - 1 : dice_diff
       pips_diff = (pips_diff < 0) ? pips_diff + 3 : pips_diff 
       return dice_diff.to_s + "D+" + pips_diff.to_s
    end

    def self.dice_gt_max(sum, max)
       compare_dice = D6System.get_dice(max) - D6System.get_dice(sum)
       return compare_dice != 0 ? compare_dice < 0 : D6System.get_pips(max) < D6System.get_pips(sum)
    end

    def self.get_spec_skill(char, ability)
        spec = find_ability(char, ability)
        return spec.skill
    end

    # Checks for dice limit in rolls (house rules)
    # Sorry, not that pretty.
    def self.exceeds_roll_limit(char, roll_str)
      max_dice = Global.read_config("d6system", "roll_max_dice")
      return false if ( (max_dice == {} ) || D6System.valid_num_roll_str(roll_str) )
      roll_params = parse_roll_params(char, roll_str)
      return nil if !roll_params
      ability = roll_params.ability
      ability_type = D6System.get_ability_type(ability)
      skill_rating = D6System.ability_rating(char, ability)
      if (ability_type == :specialization)
         skill = get_spec_skill(char, ability)
         skill_rating = add_dice(skill_rating, D6System.ability_rating(char, skill),0)  # spec rating + base skill rating
      else
        skill = ability
      end

      linked_attr = roll_params.linked_attr || D6System.get_linked_attr(skill)
      if (ability_type == :attribute && !linked_attr)
        skill_rating = "0D+0"
        linked_attr = ability
      end

      apt_rating = linked_attr ? D6System.ability_rating(char, linked_attr) : '0D+0'
      dice_total = add_dice(skill_rating, apt_rating, 0)
      return dice_gt_max(dice_total, max_dice)
    end

    # Takes a roll string, like Athletics+Body+2, or just Athletics, parses it to figure
    # out the pieces, and then makes the roll.
    def self.parse_and_roll(char, roll_str)
      if valid_num_roll_str(roll_str)
        return { dice_roll: D6System.rolling_str(char, roll_str) }
      else
        roll_params = D6System.parse_roll_params(char, roll_str)
        if (!roll_params)
          return nil
        end
        return { dice_roll: D6System.roll_ability(char, roll_params),
                 roll_modifiers: D6System.roll_modifiers(char, roll_params),
                 roll_details: D6System.roll_details(char, roll_params) }
      end
    end
    
    # Parses a roll string in the form Ability+Attr(+ or -)Modifier, where
    # everything except "Ability" is optional.
    # Can also do Attr+Attr or Attr+Attr.
    def self.parse_roll_params(char, str)
      match = /^(?<ability>[^\+\-]+)\s*(?<attr>[\+][^\d]+)?\s*(?<dice>[\+\-]\s*\d+[d|D]6?)?\s*(?<pips>[\+\-]\d+)?$/.match(str)
      return nil if !match
      
      ability = match[:ability].strip.titlecase
      if !find_ability(char, ability)
        return nil
      end

      linked_attr = match[:attr].nil? ? nil : match[:attr][1..-1].strip
      dice = match[:dice].nil? ? 0 : match[:dice].gsub(/[\s+|d|D]6?/, "").to_i  # for example convert '+2d6' to 2
      pips = match[:pips].nil? ? 0 : match[:pips].gsub(/\s+/, "").to_i

      if (linked_attr)
        ability_type = D6System.get_ability_type(linked_attr)
        if (ability_type != :attribute)
          return nil
        end
      end

      return RollParams.new(ability, dice, pips, linked_attr)
    end
    
  end
end
