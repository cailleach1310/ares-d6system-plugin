$:.unshift File.dirname(__FILE__)

module AresMUSH
  module D6System

    def self.plugin_dir
      File.dirname(__FILE__)
    end

    def self.shortcuts
      Global.read_config("d6system", "shortcuts")
    end

    def self.achievements
      Global.read_config('d6system', 'achievements')
    end
 
    def self.get_cmd_handler(client, cmd, enactor)
      case cmd.root
      when "abilities"
        return AbilitiesCmd
      when "ability"
        case cmd.switch
        when "set"
          AbilitySetCmd
        end
      when "sheet"
        return SheetCmd
      when "raise", "lower"
        return RaiseCmd
      when "advantage", "disadvantage"
        case cmd.switch
        when "raise"
          return RaiseAdvantageCmd
        when "lower"
          return LowerAdvantageCmd
        end
      when "reset"
        return ResetCmd
      when "roll"
        if (cmd.args =~ / vs /)
          return OpposedRollCmd
        else
          return RollCmd
        end
      end
    end

    def self.get_event_handler(event_name)
      nil
    end

    def self.get_web_request_handler(request)
      case request.cmd
      when "abilities"
        return AbilitiesRequestHandler
#      when "addJobRoll"
#        return AddJobRollRequestHandler
      when "addSceneRoll"
        return AddSceneRollRequestHandler
      end

    end

  end
end
