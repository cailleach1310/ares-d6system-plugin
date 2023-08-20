module AresMUSH
  module D6System
    class D6EventHandler

      def on_event(event)
         # periodic char points awards
        config = Global.read_config("d6system", "cp_cron")
        if Cron.is_cron_match?(config, event.time)
           Global.logger.debug "Character points awards."
           periodic_cp = Global.read_config("d6system", "periodic_cp")
           max_cp = Global.read_config("d6system", "max_char_hoard")
           approved = Chargen.approved_chars
           approved.each do |a|
             D6System.modify_cp(a, periodic_cp)
           end
        end

        # clear assisted heal blocks          
        config = Global.read_config("d6system", "assist_healed_cron")
        if Cron.is_cron_match?(config, event.time)
          hours = Global.read_config("d6system", "assist_heal_block")
          Global.logger.debug "Clearing #{hours}h blocks (assisted healing)."
          assist_heal_time = Global.read_config("d6system", "assist_heal_block")
          time = Time.now
          approved = Chargen.approved_chars
          approved.each do |a|
          Character.all.each do |a|
            if (a.healed != nil)
               a.healed.each do |patient|
                  if (Time.at(patient.healed_at.to_time.to_i + assist_heal_time * 3600) < time)
                     Global.logger.debug "Deleting assisted heal of #{patient.name}."
                     patient.delete
                  end
               end
            end
          end
        end

        # trigger natural healing jobs
        config = Global.read_config("d6system", "natural_heal_cron")
        if Cron.is_cron_match?(config, event.time)
          Global.logger.debug "Handling natural healing of wound levels."
          time = Time.now
          approved = Chargen.approved_chars
          approved.each do |a|
          Character.all.each do |a|
            if ((a.wound_level != D6System.level_names[0]) && (a.wound_level != "Stunned") )
               natural_heal_days = D6System.wound_levels.find { |l| l['name'] == a.wound_level }['rest_period']
               job_started = Jobs.open_requests(a).select { |j| (j.title.match("Natural Healing Roll") && j.is_active? )} != []
               if ((Time.at(a.wound_updated.to_time.to_i + natural_heal_days * 86400) < time) && !job_started)
                  Global.logger.debug "Triggering natural heal job of #{a.name}."
                  natural_heal_message = Global.read_config("d6system", "natural_heal_message")
                  difficulty = D6System.wound_levels.find { |l| l['name'] == a.wound_level }['natural_diff']
                  result = Jobs.create_job("MISC", 
                     "Natural Healing Roll for #{a.name}", 
                     "#{a.name}'s wound level of #{a.wound_level} can be improved through a natural healing roll. You have to roll against a difficulty of #{difficulty}. Recovery time span: #{natural_heal_days} days.%r%r" + natural_heal_message,
                     Game.master.system_character)
                  job = result[:job]
                  job.participants.add a
               end
            end
          end
        end

      end 

    end    
  end
end
