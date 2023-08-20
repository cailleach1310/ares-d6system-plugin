module AresMUSH
  module Scenes
    
    def self.custom_scene_data(viewer)
      # Return nil if you don't need any custom data.
      return { char_abilities: D6System.web_abilities(viewer),
               fate_points: (viewer.fate_points > 0),
               char_points: (viewer.char_points > 0) }
    end
  end
end
