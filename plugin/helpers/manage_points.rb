module AresMUSH
  module D6System
    def self.can_manage_points?(actor)
      actor && actor.has_permission?("manage_abilities")
    end
    
    def self.modify_fate(char, amount)
      max_fate = Global.read_config("d6system", "max_fate_hoard")
      fate = char.fate_points + amount
      fate = [max_fate, fate].min
      fate = [0, fate].max
      char.update(fate_points: fate)
    end
    
    def self.modify_cp(char, amount)
      max_cp = Global.read_config("d6system", "max_char_hoard")
      cp = char.xp + amount
      cp = [max_cp, cp].min
      cp = [0, cp].max
      char.update(xp: cp)
    end

  end
end
