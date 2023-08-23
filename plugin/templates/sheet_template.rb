module AresMUSH
  module D6System
    class SheetTemplate < ErbTemplateRenderer
      
      attr_accessor :char, :client, :section
      
      def initialize(char, client, section = nul)
        @char = char
        @client = client
        @section = section
        super File.dirname(__FILE__) + "/sheet.erb"
      end
     
      def approval_status
        Chargen.approval_status(@char)
      end
      
      def show_section(section)
        sections = ['abilities', 'specializations', 'advantages', 'disadvantages', 'special_abilities', 'stats']
        return true if self.section.blank?
        return true if !sections.include?(section)
        return true if !sections.include?(self.section)
        return section == self.section
      end
      
      def abilities
       list = []
        char_sorted_attr_lists(@char).each_with_index do |a, i|
          if (a)
             list << format_ability(a, i)
          end
        end
        list
      end

      def specializations
       list = []        
        @char.d6specializations.each_with_index do |a, i| 
          if (a)
             list << format_specialization(a, i)
          end
        end   
        list     
      end
        
      def advantages
        list = []
        @char.d6advantages.each do |m| 
           list << format_option(m)
        end
        list
      end
      
      def disadvantages
        list = []
        @char.d6disadvantages.each do |f|
          list << format_option(f)
        end
        list
      end
      
      def special_abilities
        list = []
        @char.d6specials.each do |f|
          list << format_option(f)
        end
        list
      end

      def stats
        list = []
        stat_list = D6System.other_stats(@char)
        stat_list[1], stat_list[2] = stat_list[2], stat_list[1]    #swap char points with strength damage for a better display 
        stat_list.each_with_index do |st, i| 
          list << format_stat(st, i)
        end
        list.join("")
      end
       
      def format_stat(st, i)
        name = "  %xh#{st['name']}%xn "
        linebreak = ((i+1) % 2 == 1) ? "%r" : ""
        rating = " #{st['rating']}"
        dots = 43 - name.length
        "#{linebreak}#{name}#{rating.rjust(dots,".")}  "
      end

      def format_ability(a, i)
         linebreak = ((i+1) % 3 == 1) ? "%r" : ""
         if (a['name'] != "<empty>")
           name = "  %xh#{a['name']}%xn "
           rating = " #{a['rating']}"
           dots = 30 - name.length
           "#{linebreak}#{name}#{rating.rjust(dots,".")}  "
        else
            "#{linebreak}                          "
        end
      end

      def format_specialization(a, i)
         linebreak = ((i+1) % 2 == 1) ? "%r" : ""
         if (a.name != "<empty>")
           name = "  %xh#{D6System.spec_pretty(a)}%xn "
           rating = " #{a.rating}"
           dots = 43 - name.length
           "#{linebreak}#{name}#{rating.rjust(dots,".")}  "
        else
            "#{linebreak}                          "
        end
      end

      def format_option(a)
        return "  %xh#{a.name}%xn(R#{a.rank}): #{a.details}"
      end

      def section_line(title)
        @client.screen_reader ? title : line_with_text(title)
      end

      def attribute_skills(char, attribute)
         D6System.skill_list(char,attribute,false).unshift({'name' => attribute.upcase, 'rating' => D6System.ability_rating(char,attribute) })
      end

      def build_column(char, attributes)
        column = []
        attributes.each do |attr|
           if (attr == "Extranormal")
              D6System.extranormal_attributes.each do |a|
                 if (D6System.get_dice(D6System.ability_rating(char,a)) > 0)
                    attribute_skills(char,a).each do |m|
                       column << m
                    end
                    column << { 'name' => '<empty>', 'rating' => "" }
                 end
              end
           else
              attribute_skills(char,attr).each do |m|
                 column << m
              end
              column << { 'name' => '<empty>', 'rating' => "" }
           end
        end
        return column
      end

      def char_sorted_attr_lists(char)
        list = []
        sheet_columns = D6System.sheet_columns   
        column_1 = build_column(char, sheet_columns[0].split(" "))
        column_2 = build_column(char, sheet_columns[1].split(" "))
        column_3 = build_column(char, sheet_columns[2].split(" "))
        i = 0
        len = [ column_1.length, column_2.length, column_3.length ].max
        while (i < len)
          if (column_1 != [])
            list << column_1.shift
          else
            list << { 'name' => '<empty>', 'rating' => "" }
          end
          if (column_2 != [])
            list << column_2.shift
          else
            list << { 'name' => '<empty>', 'rating' => "" }
          end
          if (column_3 != [])
            list << column_3.shift
          else
            list << { 'name' => '<empty>', 'rating' => "" }
          end
          i = i + 1
        end
        return list
      end

    end
  end
end
