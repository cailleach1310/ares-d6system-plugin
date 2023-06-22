module AresMUSH
  module D6System
    
    def self.dice_to_roll_for_ability(char, roll_params)
      ability = roll_params.ability
      linked_attr = roll_params.linked_attr || D6System.get_linked_attr(ability)
      ability_type = D6System.get_ability_type(ability)
      skill_rating = D6System.ability_rating(char, ability)
      
      if (ability_type == :attribute && !linked_attr)
        skill_rating = "0D+0"
        linked_attr = ability
      end
      
      apt_rating = linked_attr ? D6System.ability_rating(char, linked_attr) : '0D+0'
      
      dice = add_dice(skill_rating, apt_rating, roll_params.dice)
      Global.logger.debug "#{char.name} rolling #{ability} dice=#{roll_params.dice} pips=#{roll_params.pips} skill=#{skill_rating} linked_attr=#{linked_attr} apt=#{apt_rating}"
      
      dice
    end

    def self.add_dice(dice1, dice2, modifier)
       dice_sum = dice1.split("D")[0].to_i + dice2.split("D")[0].to_i
       pips_sum = dice1.split("+")[1].to_i + dice2.split("+")[1].to_i
       dice_sum = dice_sum + pips_sum / 3 + modifier
       return dice_sum.to_s + "D+" + (pips_sum % 3).to_s
    end

    # Takes a roll string, like Athletics+Body+2, or just Athletics, parses it to figure
    # out the pieces, and then makes the roll.
    def self.parse_and_roll(char, roll_str)
      values = []
      if (roll_str.match(/^\d+[d|D]6?\+?\d?/) != nil)
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
      
      ability = match[:ability].strip
      linked_attr = match[:attr].nil? ? nil : match[:attr][1..-1].strip
      dice = match[:dice].nil? ? 0 : match[:dice].gsub(/[\s+|d|D]6?/, "").to_i  # convert '+2d6' to 2
      pips = match[:pips].nil? ? 0 : match[:pips].gsub(/\s+/, "").to_i

      if (linked_attr)
        ability_type = D6System.get_ability_type(linked_attr)
        if (ability_type != :attribute)
          return nil
        end
      end

      return RollParams.new(ability, dice, pips, linked_attr)
    end
    
 #   def self.is_specialty(char,ability_name)
 #      char.d6specialties.each do |spec|
 #         if (spec.name == ability_name)
 #            return true
 #         end
 #      end
 #      return false
 #   end

  end
end
