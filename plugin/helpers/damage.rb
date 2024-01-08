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

    def self.is_healer?(char)
      skill_list = Global.read_config("d6system","heal_skills")
      heal_skill = D6System.get_highest_skill(char, skill_list)
      rating = D6System.ability_rating(char, heal_skill)
      return (rating != "0D")
    end

    def self.wounded_chars()
       Chargen.approved_chars.select { |char| (char.wound_level != level_names[0]) && (char.wound_level != "Stunned") }
    end

    def self.healed_by(char)
      Chargen.approved_chars.select { |a| is_healer?(a) }.each do |c|
         patient = c.healed.find(name: char.name).first
         if (patient)
            return c.name
         end
      end
      return "N/A"
    end

    def self.general_field(char, field_type, value)
      case field_type

      when 'name'
        Demographics.name_and_nickname(char)
    
      when 'handle'
        char.handle ? "@#{char.handle.name}" : ""
        
      when 'wound_level'
        char.wound_level

      when 'wound_updated'
        char.wound_updated.to_s.split(" ")[0..1].join(" ")

      when 'healed_by'
        healed_by(char)
          
      else 
        nil
      end
    end

    def self.set_scene_damage_web(request, enactor)
      scene = Scene[request.args[:id]]
      char_name = request.args[:char_name]
      wound_level = request.args[:wound_level] 
      return { error: t('dispatcher.not_allowed') } if !enactor.has_permission?("manage_damage")
      
      if (!scene)
        return { error: t('webportal.not_found') }
      end

      if !D6System.wound_levels.map { |a| a["name"] }.include?(wound_level)
         return { error: "That is not a valid wound level!" }
      end
        
       char = Character.named(char_name)
       return { error: t('d6system.no_such_char', :name => char_name) } if !char
       D6System.wound_set(char, wound_level)
       message = "#{enactor.name} sets #{char.name}'s wound level to #{char.wound_level}."
       return { message: message }
    end

    def self.web_heal(request, enactor)
      scene = Scene[request.args[:id]]
      char_name = request.args[:heal_name]
      fate_roll = request.args[:fate] == "true"  # the parameter comes as a string and has to be converted to boolean value
      cp_roll = request.args[:cp] == "true"  # the parameter comes as a string and has to be converted to boolean value
      message = ""
      char = Character.named(char_name)
      return { error: t('d6system.no_such_char', :name => char_name) } if !char

      if !enactor.is_approved?
         return { error: t('dispatcher.not_allowed') }
      end

      if !D6System.is_healer?(enactor)
         return { error: t('d6system.no_heal_ability') }
      end

      if (!scene)
        return { error: t('webportal.not_found') }
      end

      skill_list = Global.read_config("d6system","heal_skills")
      heal_skill = D6System.get_highest_skill(enactor, skill_list)
      roll_str = heal_skill

      wound_level = char.wound_level
      return { error: t('d6system.no_wounds_to_heal') } if (wound_level == D6System.level_names[0])

      patient = enactor.healed.find(name: char_name).first
      if (patient != nil)
         hours = Global.read_config("d6system", "assist_heal_block")
         return { error: t('d6system.wait_heal', :name => char_name, :hours => hours) }
      end

      # get difficulty of wound level
      assist_diff = D6System.get_assisted_difficulty(wound_level)
      # char point spent?
      if cp_roll
         if (enactor.char_points > 0)
            enactor.update(char_points: enactor.char_points - 1)
            Achievements.award_achievement(enactor, "d6_cp_spent")
            message = message + t('d6system.spends_char_point',
              :name => enactor.name) + "%r"
            roll_str = D6System.add_cp_die(roll_str)  # modify roll_str, add 1D to it.
         else
            message = message + t('d6system.no_cp_point', :name => enactor.name) + "%r"
         end
      end
      # calculate roll
      dice_result = D6System.parse_and_roll(enactor, roll_str)
      overall_result = D6System.get_result(dice_result[:dice_roll])

      # fate roll ?
      if fate_roll
         if (enactor.fate_points > 0)
            enactor.update(fate_points: enactor.fate_points - 1)
            message = message + t('d6system.spends_fate_point', 
              :name => enactor.name) + "%r"
         else
            message = message + t('d6system.no_fate_point', :name => enactor.name) + "%r"
            fate_roll = false
         end
      end

      overall_total = fate_roll ? overall_result * 2 : overall_result
      simple_success = D6System.get_success_title(dice_result[:dice_roll])
      success_title = (simple_success != "%xrCritical Failure!%xn") ? D6System.get_diff_success_title(overall_total - assist_diff) : simple_success
      Global.logger.debug "success title: #{success_title}, overall total: #{overall_total}, assist_diff: #{assist_diff}"
      message = message + t('d6system.difficulty_roll_result',
        :name => enactor.name,
        :roll => roll_str,
        :dice => D6System.print_dice(dice_result[:dice_roll]),
        :details => dice_result[:roll_details],
        :total => overall_total,
        :diff_result => success_title,
        :difficulty => assist_diff
      )
      # evaluate result
      if (success_title == "%xrCritical Failure!%xn")
         D6System.wound_worsen(char)
         Global.logger.info "#{enactor.name} critically fails healing #{char.name}'s wound. New wound level is #{char.wound_level}."
         message = message + "%r" + t('d6system.heal_crit_fail', :name => char.name, :enactor => enactor.name, :wound_level => char.wound_level)
      elsif (overall_total >= assist_diff)
         D6System.wound_heal(char)
         Global.logger.info "#{enactor.name} heals #{char.name} to wound level #{char.wound_level}."
         message = message + "%r" + t('d6system.char_healed', :name => char.name, :enactor => enactor.name, :wound_level => char.wound_level)
      else
         Global.logger.info "#{enactor.name} tries to heal #{char.name} but fails."
         message = message + "%r" + t('d6system.heal_failed', :name => char.name, :enactor => enactor.name, :wound_level => char.wound_level)
      end

      D6System.add_to_healed(enactor, char.name)
      return { message: message }
    end

  end
end
