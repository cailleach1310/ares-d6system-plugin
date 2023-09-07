module AresMUSH
  module D6System
    module StartingAbilities
      def self.config
        Global.read_config("d6system", "starting_abilities") || {}
      end
      
      def self.check_config
        msg = ""
        config.each do |group_type, groups|
          groups.each do |group_name, group_config| 
            abilities = group_config["abilities"]
              abilities.each do |ability, rating|
              if !is_ability(ability)
                msg = msg + "%r" + t('d6system.starting_ability_config_error', :group => group_type, :group_name => group_name, :ability => ability)
              end
            end
          end
        end
        if (msg != "")
           msg = "%xh%xr" + msg + "%xn"
        else
           msg = "%r%xh%xgOK!%xn"
        end
        msg = "Checking starting abilities." + msg
        return msg
      end

      def self.is_ability(ability)
         return (D6System.get_ability_type(ability) != :specialization) || ((ability =~ /\(/) != nil)
      end

      def self.get_abilities_for_char(char)
        abilities = {}
        
        D6System.attr_names.each do |a|
          if !D6System.extranormal_attributes.include?(a)
             abilities[a] = '1D'
          else
             abilities[a] = '0D'
          end
        end
        D6System.skill_names.each do |a|
          abilities[a] = '0D'
        end
        
        groups = get_groups_for_char(char)
        groups.each do |k, v|
          group_abilities = v["abilities"]
          next if !group_abilities
          group_abilities.each do |ability, rating|
            if (!abilities.has_key?(ability) || abilities[ability] < rating)
              abilities[ability] = rating
            end
          end
        end
        abilities
      end 
      
      def self.get_groups_for_char(char)
        groups = {}
        config.each do |group, group_config|
          if (group == "Everyone")
            groups[group] = group_config
          else
            group_val = char.group(group)
            next if !group_val
            group_key = group_config.keys.find { |k| k.downcase == group_val.downcase }
            tmp = group_config[group_key]
            next if !tmp
            groups[group_val] = tmp
          end
        end
        groups
      end 
    end
  end
end
