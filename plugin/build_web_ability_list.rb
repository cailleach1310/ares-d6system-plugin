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
             specializations: specialization_list(char),
             advantages: build_chargen_list(char, D6System.advantages),
             disadvantages: build_chargen_list(char, D6System.disadvantages),
             special_abilities: build_chargen_list(char, D6System.special_abilities)
          }
        else
         if (show_sheet)
          {
            abilities_1: build_column(char, D6System.sheet_columns[0].split(" ")),
            abilities_2: build_column(char, D6System.sheet_columns[1].split(" ")),
            abilities_3: build_column(char, D6System.sheet_columns[2].split(" ")),
            specializations: specialization_list(char),
            advantages: option_list(char.d6advantages),
            disadvantages: option_list(char.d6disadvantages),
            special_abilities: option_list(char.d6specials),
#            other_stats: D6System.other_stats(char),
            show_sheet: show_sheet,
            character_points: char.character_points
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

      def specialization_list(char)
        list = []
        char.d6specializations.each do |s|
           spec_name = s.name + " (" + s.skill + ")"
           list << { name: spec_name, rating: s.rating } 
        end
        return list
      end

      def option_list(option_list)
        list = []
        option_list.each do |s|
           list << { name: s.name, rating: s.rank, details: s.details }
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
           ability = D6System.find_ability(char, a['name'])
           if (ability)
             max = Global.read_config('d6system', 'max_rank_specials')
             cost = (D6System.get_ability_type(a['name']) == :special_ability) ? D6System.specials_cost(a) : nil
             ranks = (D6System.get_ability_type(a['name']) == :special_ability) ? (1..max).to_a : D6System.option_ranks(a)
             list << { name: a['name'], rating: ability.rank, details: ability.details, ranks: ranks, cost: cost }
           end
        end
        return list
      end

    end
  end
end
