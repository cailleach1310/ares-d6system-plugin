module AresMUSH
  module D6System
    class CharPointsCronHandler
      def on_event(event)
        config = Global.read_config("d6system", "cp_cron")
        return if !Cron.is_cron_match?(config, event.time)
        
        Global.logger.debug "Character points awards."
        
        periodic_cp = Global.read_config("d6system", "periodic_cp")
        max_xp = Global.read_config("d6system", "max_char_hoard")
        
        approved = Chargen.approved_chars
        approved.each do |a|
          D6System.modify_cp(a, periodic_cp)
        end
      end
    end    
  end
end
