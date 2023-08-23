module AresMUSH
  module D6System
    class WoundLevelsRequestHandler
      def handle(request)

        wound_levels = D6System.wound_levels.map { |a| {
          name: a['name'],
          effect: a['effect'],
          assist_diff: a['assist_diff'] || "-",
          natural_diff: a['natural_diff'] || "-",
          rest_period: a['rest_period'] || "-"
        }}
        
        {
          wound_levels_blurb: Global.read_config("d6system", "wound_levels_blurb"),
          wound_levels: wound_levels
        } 
      end
    end
  end
end
