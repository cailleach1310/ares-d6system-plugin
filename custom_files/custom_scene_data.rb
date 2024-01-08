module AresMUSH
  module Scenes
    
    def self.custom_scene_data(viewer)
      # Return nil if you don't need any custom data.
      return { char_abilities: D6System.web_abilities(viewer),
               fate_points: (viewer.fate_points > 0),
               char_points: (viewer.char_points > 0),
               wound_levels: viewer.has_permission?("manage_damage") ? D6System.wound_levels.map{ |a| a['name'] } : nil,
               can_heal: D6System.is_healer?(viewer)
             }
    end
  end
end
