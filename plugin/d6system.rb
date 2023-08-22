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
      when "option"
        case cmd.switch
        when "set"
          return OptionSetCmd
        when "add"
          return OptionSetCmd
        when "remove"
          return OptionSetCmd
        end
      when "spec"
        case cmd.switch
        when "add", "remove"
          return SpecAddCmd
        end
      when "reset"
        return ResetCmd
      when "roll"
        if (cmd.args =~ / vs /)
          return OpposedRollCmd
        else
          return RollCmd
        end
      when "fate", "cp"
        return PointsAwardCmd  
      when "heal"
        return HealWoundCmd
      when "wound"
        case cmd.switch
          when "set"
            return SetWoundLevelCmd
          when "list"
            return WoundListCmd
        end
      end
    end

    def self.get_event_handler(event_name)
      case event_name
      when "CronEvent"
        return D6EventHandler
      end
    end

    def self.get_web_request_handler(request)
      case request.cmd
      when "abilities"
        return AbilitiesRequestHandler
      when "addJobRoll"
        return AddJobRollRequestHandler
      when "addSceneRoll"
        return AddSceneRollRequestHandler
      when "resetD6Abilities"
        return ResetAbilitiesRequestHandler
      end

    end

  end
end
