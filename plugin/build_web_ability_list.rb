module AresMUSH
  module D6System
    class WebAbilityListBuilder

      def build(char, viewer, chargen)

        is_owner = (viewer && viewer.id == char.id)

        show_sheet = D6System.can_view_sheets?(viewer) || is_owner

        if (chargen)
          {
             attrs: build_chargen_ability_list(char, "attribute"),
             skills: build_chargen_ability_list(char, "skill"),
             advantages: build_chargen_list(char, D6System.advantages)
          }
        else
         if (show_sheet)
          {
            abilities_1: build_column(char, D6System.sheet_columns[0].split(" ")),
            abilities_2: build_column(char, D6System.sheet_columns[1].split(" ")),
            abilities_3: build_column(char, D6System.sheet_columns[2].split(" ")),
#            specialties: specialty_list(char),
#            advantages: advantage_list(char,chargen),
#            other_stats: D6System.other_stats(char),
            show_sheet: show_sheet,
#            xp: char.xp
          }
         end
        end
      end

      def build_column(char, attributes)
        column = []
        attributes.each do |attr|
           column << { attribute: attr, rating: D6System.ability_rating(char, attr), skills: D6System.skill_list(char,attr,false) }
        end
        return column
      end

      def specialty_list(char)
        list = []
        char.d6specialties.each do |s|
           list << { name: s.name + " (" + s.skill + ")" } 
        end
        return list
      end

      def build_chargen_ability_list(char, ability_type)
         case ability_type
         when "attribute"
            ability_list = D6System.attributes
         when "skill"
            ability_list = D6System.skills
         else
            abiliy_list = nil
         end
         list = []
         ability_list.each do |s|
            rating = D6System.ability_rating(char, s['name'])
            rating = rating.split("+")[1] ? rating : rating + "+0"
            if (ability_type == "attribute")
               list << { name: s['name'], rating: rating, desc: s['desc'] }
            else
                if (ability_type == "skill")
                   list << { name: s['name'], rating: rating, desc: s['desc'], linked_attr: s['linked_attr'] }
                end
            end 
         end
         return list
      end

      def build_chargen_list(char, cg_list)
        list = []
        cg_list.each do |a|
           rating = D6System.simple_rating(char, a['name'])
           list << { name: a['name'], rating: rating, desc: a['desc'] }
        end
        return list
      end

    end
  end
end
