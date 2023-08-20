module AresMUSH
  module D6System
    class HealWoundCmd
      include CommandHandler
      
      attr_accessor :name, :fate_roll, :cp_roll

      def parse_args
        self.name = cmd.args
        self.fate_roll = cmd.switch_is?("fate") || cmd.switch_is?("all")
        self.cp_roll = cmd.switch_is?("cp") || cmd.switch_is?("all")
      end

      def required_args
        [ self.name ]
      end
      
      def handle
        message = ""
        ClassTargetFinder.with_a_character(self.name, client, enactor) do |model|
        skill_list = Global.read_config("d6system","heal_skills")
        heal_skill = D6System.get_highest_skill(enactor, skill_list)
        rating = D6System.ability_rating(enactor, heal_skill)

        if (rating == "0D")
           client.emit_failure t('d6system.no_heal_ability')
           return
        else
           roll_str = heal_skill
        end

        wound_level = model.wound_level
        if (wound_level == D6System.level_names[0])
           client.emit_failure t('d6system.no_wounds_to_heal')
           return
        end

        patient = enactor.healed.find(name: model.name).first
        if (patient != nil)
           hours = Global.read_config("d6system", "assist_heal_block")
           client.emit_failure t('d6system.wait_heal', :name => model.name, :hours => hours)
           return
        end

        # get difficulty of wound level
        assist_diff = D6System.get_assisted_difficulty(wound_level)
        # char point spent?
        if self.cp_roll
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
        if self.fate_roll
           if (enactor.fate_points > 0)
              enactor.update(fate_points: enactor.fate_points - 1)
              message = message + t('d6system.spends_fate_point', 
                :name => enactor.name) + "%r"
           else
              message = message + t('d6system.no_fate_point', :name => enactor.name) + "%r"
              self.fate_roll = false
           end
        end

        overall_total = self.fate_roll ? overall_result * 2 : overall_result
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
           D6System.wound_worsen(model)
           Global.logger.info "#{enactor.name} critically fails healing #{model.name}'s wound. New wound level is #{model.wound_level}."
           message = message + "%r" + t('d6system.heal_crit_fail', :name => model.name, :enactor => enactor.name, :wound_level => model.wound_level)
        elsif (overall_total >= assist_diff)
           D6System.wound_heal(model)
           Global.logger.info "#{enactor.name} heals #{model.name} to wound level #{model.wound_level}."
           message = message + "%r" + t('d6system.char_healed', :name => model.name, :enactor => enactor.name, :wound_level => model.wound_level)
        else
           Global.logger.info "#{enactor.name} tries to heal #{model.name} but fails."
           message = message + "%r" + t('d6system.heal_failed', :name => model.name, :enactor => enactor.name, :wound_level => model.wound_level)
        end
       end
       D6System.add_to_healed(enactor, self.name)
       D6System.emit_results message, client, enactor_room, false
     end

    end
  end
end
