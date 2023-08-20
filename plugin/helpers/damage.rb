module AresMUSH
  module D6System

    def self.wound_levels
       return Global.read_config("d6system", "wound_levels")
    end

    def self.level_names
       return wound_levels.map { |a| a["name"] }
    end

    def self.wound_set(char, level)
       char.update(wound_level: level)
       char.update(wound_updated: Time.now)
       return
    end

    def self.wound_heal(char)
       i = level_names.index(char.wound_level)
       new_level = (i == 2) ? level_names[0] : level_names[i-1]
       char.update(wound_level: new_level)
       char.update(wound_updated: Time.now)
    end   

    def self.wound_worsen(char)
       i = level_names.index(char.wound_level)
       first_index = level_names.index("Stunned")
       last_index = level_names.length - 1
       if ((i > first_index) && (i < last_index))
          new_level = level_names[i+1]
          char.update(wound_level: new_level)
          char.update(wound_updated: Time.now)
       end
    end

    def self.get_assisted_difficulty(level)
       i = level_names.index(level)
       return wound_levels[i]["assist_diff"]
    end

    def self.get_natural_difficulty(level)
       i = level_names.index(level)
       return wound_levels[i]["natural_diff"]
    end

    def self.add_to_healed(char, name)
       healed = D6Healed.create(character: char, name: name, healed_at: Time.now)
    end

    def self.get_highest_skill(enactor, skill_list)
       max_skill = ""  
       max_rating = "0D"
       skill_list.each do |skill|
          rating = D6System.add_dice(D6System.ability_rating(enactor, skill['name']), D6System.ability_rating(enactor, D6System.get_linked_attr(skill['name'])), skill['modifier'])
          if (D6System.get_dice(max_rating) < D6System.get_dice(rating))
             max_rating = rating
             max_skill = skill['name']
          elsif ((D6System.get_dice(max_rating) == D6System.get_dice(rating)) && (D6System.get_pips(max_rating) < D6System.get_pips(rating)))
             max_rating = rating
             max_skill = skill['name']
          end
       end
       return max_skill
    end

  end
end
