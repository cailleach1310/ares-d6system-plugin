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

    def self.attributes_blurb
      Global.read_config("d6system", "attributes_blurb")
    end

    def self.skills_blurb
      Global.read_config("d6system", "skills_blurb")
    end

    def self.advantages_blurb
      Global.read_config("d6system", "advantages_blurb")
    end

    def self.disadvantages_blurb
      Global.read_config("d6system", "disadvantages_blurb")
    end

    def self.extranormal_attributes
      Global.read_config("d6system", "extranormal_attributes")
    end

    def self.sheet_columns
      Global.read_config("d6system", "sheet_columns")
    end

    def self.can_view_sheets?(actor)
      return true if Global.read_config("d6system", "public_sheets")
      return false if !actor
      actor.has_permission?("view_sheets")
    end

    def self.get_linked_attr(skill_name)
       skill = D6System.skills.find { |s| s['name'] == skill_name }
       if !(skill)
          return nil
       else
          return skill['linked_attr']
       end
    end

    def self.other_stats(char)
      list = []
      list << { 'name' => 'Body Points', 'rating' => char.body_points }
      list << { 'name' => 'Fate Points', 'rating' => char.fate_points }
      list << { 'name' => 'Char Points', 'rating' => char.xp }
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

#    def self.disadvantage_names
#       D6System.disadvantages.map { |a| a['name'].titlecase }
#    end

    def self.find_ability(char, ability_name)
      ability_name = ability_name.titlecase
      ability_type = get_ability_type(ability_name)
      case ability_type
      when :attribute
        char.d6attributes.find(name: ability_name).first
      when :skill
        char.d6skills.find(name: ability_name).first
      when :advantage
        char.d6advantages.find(name: ability_name).first
#      when :disadvantage
#        char.d6disadvantages.find(name: ability_name).first
#      when :specialty
#        char.d6specialties.find(name: ability_name).first
      else
        nil
      end
    end

    def self.get_ability_type(ability)
      ability = ability.titlecase
      if (attr_names.include?(ability))
        return :attribute
      elsif (skill_names.include?(ability))
        return :skill
      elsif (advantage_names.include?(ability))
        return :advantage
#      elsif (disadvantage_names.include?(ability))
#        return :disadvantage
#      else
#        return :specialty
      end        
    end

  end
end
