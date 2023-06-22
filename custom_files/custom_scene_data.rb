module AresMUSH
  module Scenes
    
    def self.custom_scene_data(viewer)
      return { char_abilities: D6System.web_abilities(viewer),
               fate_points: (viewer.fate_points > 0) }

    end
  end
end
