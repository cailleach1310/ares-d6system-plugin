module AresMUSH
  module D6System

    # Makes an ability roll and returns the raw dice results.
    # Good for when you're doing a regular roll because you can show the raw dice and
    # use the other methods in this class to get the success level and title to display.
    def self.roll_ability(char, roll_params)
      rolls = []
      combined_dice = D6System.dice_to_roll_for_ability(char, roll_params)
      total_dice = get_dice(combined_dice)
      modifiers = get_pips(combined_dice) + roll_params.pips
      
      rolls << wild_die(nil)
      rolls << roll_dice(total_dice-1)
      Global.logger.info "#{char.name} rolling #{combined_dice} total_dice=#{total_dice} result=#{rolls}"
      return rolls
    end

    def self.roll_modifiers(char, roll_params)
      combined_dice = D6System.dice_to_roll_for_ability(char, roll_params)
      modifiers = get_pips(combined_dice) + roll_params.pips
      return modifiers
    end

    def self.roll_details(char, roll_params)
      dice_str = D6System.dice_to_roll_for_ability(char, roll_params)
      modifier = get_pips(dice_str) + roll_params.pips
      details = modifier < 0 ? get_dice(dice_str).to_s + "D" + modifier.to_s : get_dice(dice_str).to_s + "D+" + modifier.to_s 
      return details
    end

    def self.rolling_str(char, roll_str)
      rolls = []
      dice = get_dice(roll_str)
      modifier = get_pips(roll_str)

      rolls << wild_die(nil)
      rolls << roll_dice(dice-1)
      Global.logger.info "#{char.name} rolling #{roll_str} dice=#{dice} result=#{rolls} modifier=#{modifier}"
      return rolls
    end

    def self.get_dice(dicestring)
      return dicestring.split("D")[0].to_i
    end

    def self.get_pips(dicestring)
      return dicestring.split("+")[1].to_i
    end

    def self.valid_roll_str(dicestring)
     return (dicestring.match(/\d+[d|D]6?\+?\d?/) != nil)
    end

    def self.wild_die(prev_dice)
      dice = []
      if (prev_dice != nil)
         prev_dice.each do |d|
            dice << d
         end
      end
      wild = 1 + rand(6)
      dice << wild
      if (wild == 6)
        return wild_die(dice)
      end
      return dice
    end

    def self.roll_dice(dice)
      dice.times.collect { 1 + rand(6) }
    end   

    def self.get_result(die_results)
      result = 0
      normal_dice = die_results[1].sort
      wild_die = die_results[0]
      wild_die.each_with_index do |w, index|
        if (w == 1) && (index == 0)
          normal_dice.pop  #remove the highest normal die, and the wild die '1' doesn't count. (crit fail only on a '1' on the first wild die roll))
        else
          result = result + w
        end
      end  
      normal_dice.each do |d|
        result = result + d
      end
      result        
    end

    def self.get_success_title(die_results)
      case die_results[0][0]  # first wild die roll
      when 6
        return "%xgCritical Success!%xn"
      when 1
        return "%xrCritical Failure!%xn"
      else
        return "%xySuccess!%xn"
      end
    end

    def self.emit_results(message, client, room, is_private)
      if (is_private)
        client.emit message
      else
        room.emit message
        channel = Global.read_config("d6system", "roll_channel")
        if (channel)
          Channels.send_to_channel(channel, message)
        end
        
        if (room.scene)
          Scenes.add_to_scene(room.scene, message)
        end
        
      end
      Global.logger.info "D6 roll results: #{message}"
    end

    # Returns either { message: roll_result_message }  or  { error: error_message }
    def self.determine_web_roll_result(request, enactor)
      
      roll_str = request.args[:roll_string]
      difficulty = (request.args[:difficulty] || '0').to_i
      vs_roll1 = request.args[:vs_roll1] || ""
      vs_roll2 = request.args[:vs_roll2] || ""
      vs_name1 = (request.args[:vs_name1] || "").titlecase
      vs_name2 = (request.args[:vs_name2] || "").titlecase
      pc_name = request.args[:pc_name] || ""
      pc_ability = request.args[:pc_ability] || ""
      fate_roll = request.args[:fate] == "true"  # the parameter comes as a string and has to be converted to boolean value

      # ------------------
      # VS ROLL
      # ------------------
      if (!vs_roll1.blank?)
        result = ClassTargetFinder.find(vs_name1, Character, enactor)
        model1 = result.target
        if (!model1 && !valid_roll_str(vs_roll1))
          vs_roll1 = "2D+0"
        end
                              
        result = ClassTargetFinder.find(vs_name2, Character, enactor)
        model2 = result.target
        vs_name2 = model2 ? model2.name : vs_name2
                              
        if (!model2 && !valid_roll_str(vs_roll2))
          vs_roll2 = "2D+0"
        end
        
        if !model1
          die_result1 = D6System.parse_and_roll(enactor, vs_roll1)
          total1 = D6System.get_result(die_result1[:dice_roll]) + D6System.get_pips(vs_roll1)
        else
          die_result1 = D6System.parse_and_roll(model1, vs_roll1)
          total1 = D6System.get_result(die_result1[:dice_roll]) + die_result1[:roll_modifiers]
        end

        if !model2
          die_result2 = D6System.parse_and_roll(enactor, vs_roll1)
          total2 = D6System.get_result(die_result2[:dice_roll]) + D6System.get_pips(vs_roll2)
        else
          die_result2 = D6System.parse_and_roll(model1, vs_roll2)
          total2 = D6System.get_result(die_result2[:dice_roll]) + die_result2[:roll_modifiers]
        end

        if (!die_result1 || !die_result2)
          return { error: t('d6system.unknown_roll_params') }
        end
        
        success_title1 = D6System.get_success_title(die_result1[:dice_roll])
        success_title2 = D6System.get_success_title(die_result2[:dice_roll])
          
        results = D6System.opposed_result_title(vs_name1, total1, vs_name2, total2)
        
        message = t('d6system.opposed_roll_result', 
           :name1 => !model1 ? t('d6system.npc', :name => vs_name1) : model1.name,
           :name2 => !model2 ? t('d6system.npc', :name => vs_name2) : model2.name,
           :roll1 => vs_roll1,
           :roll2 => vs_roll2,
           :dice1 => D6System.print_dice(die_result1[:dice_roll]),
           :dice2 => D6System.print_dice(die_result2[:dice_roll]),
           :total1 => total1,
           :total2 => total2,
           :success1 => success_title1,
           :success2 => success_title2,
           :result => results)  

      # ------------------
      # ROLL for other characters
      # ------------------
      # No fate option here, as this should only be used by the respective player.
      # Also: NPC rolls with a dice number

      elsif (!pc_name.blank?)
        char = Character.find_one_by_name(pc_name)

        if (!char && !valid_roll_str(pc_ability) )
          pc_ability = "1D+0"
        end

        # NPC roll 
        if !char
           roll = D6System.parse_and_roll(enactor, pc_ability)
           overall_result = get_result(roll[:dice_roll]) + get_pips(pc_ability)
           success_title = get_success_title(roll[:dice_roll])
           return { message: t('d6system.num_roll_result',
            :name => "#{pc_name} (#{enactor.name})",
            :roll => pc_ability,
            :dice => D6System.print_dice(roll[:dice_roll]),
            :total => overall_result,
            :success => success_title
          ) }

        # PC roll
        else
          if (pc_ability != "")
             roll = D6System.parse_and_roll(char, pc_ability)
             overall_result = get_result(roll[:dice_roll]) + roll[:roll_modifiers]
             if (difficulty == 0)
                success_title = D6System.get_success_title(roll[:dice_roll])
                return { message: t('d6system.simple_roll_result',
                  :name => "#{pc_name} (#{enactor.name})",
                  :roll => pc_ability,
                  :dice => D6System.print_dice(roll[:dice_roll]),
                  :details => roll[:roll_details],
                  :total => overall_result,
                  :success => success_title) }
             else
                success_title = D6System.get_diff_success_title(overall_result - difficulty)
                return { message: t('d6system.difficulty_roll_result',
                  :name => "#{pc_name} (#{enactor.name})",
                  :roll => pc_ability,
                  :dice => D6System.print_dice(roll[:dice_roll]),
                  :details => roll[:roll_details],
                  :total => overall_result,
                  :diff_result => success_title,
                  :difficulty => difficulty
                ) }
             end
          else
             return { error: "That is not a valid roll." }
          end
       end
           
      # ------------------
      # SELF ROLL
      # ------------------
      
      else
        message = ""

        roll = D6System.parse_and_roll(enactor, roll_str)
        overall_result = get_result(roll[:dice_roll]) + roll[:roll_modifiers]

        if fate_roll
           if (enactor.fate_points > 0)
              enactor.update(fate_points: enactor.fate_points - 1)
              Achievements.award_achievement(enactor, "d6_fate_spent")
              message = message + t('d6system.spends_fate_point',
               :name => char ? char.name : enactor.name) + "%r"
              overall_result = overall_result.to_s + " --> " + (2 * overall_result).to_s
           else
              message = message + t('d6system.no_fate_point', :name => char ? char.name : enactor.name) + "%r"
           end
        end
        if (difficulty == 0)
           success_title = D6System.get_success_title(roll[:dice_roll])
           message = message + t('d6system.simple_roll_result',
             :name => enactor.name,
             :roll => roll_str,
             :dice => D6System.print_dice(roll[:dice_roll]),
             :details => roll[:roll_details],
             :total => overall_result,
             :success => success_title
             )
        else
           success_title = D6System.get_diff_success_title(overall_result - difficulty)
           message = message + t('d6system.difficulty_roll_result',
             :name => enactor.name,
             :roll => roll_str,
             :dice => D6System.print_dice(roll[:dice_roll]),
             :details => roll[:roll_details],
             :total => overall_result,
             :diff_result => success_title,
             :difficulty => difficulty
           )
        end 
      end

      Achievements.award_achievement(enactor, "d6_roll")
      return { message: message }
    end

  end
end