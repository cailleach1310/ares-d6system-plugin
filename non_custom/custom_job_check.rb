module AresMUSH
  module Jobs
    
    def self.custom_job_check(viewer)
      return { char_abilities: D6System.web_abilities(viewer),
               fate_points: (viewer.fate_points > 0),
               char_points: (viewer.char_points > 0) }
    end
  end
end
