module AresMUSH
  module D6System
    class WebChargenInfoBuilder

      def build()
        {
          attrs_blurb: Website.format_markdown_for_html(D6System.attributes_blurb),
          skills_blurb: Website.format_markdown_for_html(D6System.skills_blurb),
          specializations_blurb: Website.format_markdown_for_html(D6System.specializations_blurb),
          advantages_blurb: Website.format_markdown_for_html(D6System.advantages_blurb),
          disadvantages_blurb: Website.format_markdown_for_html(D6System.disadvantages_blurb),
          special_abilities_blurb: Website.format_markdown_for_html(D6System.specials_blurb),

          skillnames: D6System.skill_names,
          advantages: create_option_list("advantage"),
          disadvantages: create_option_list("disadvantage"),
          special_abilities: create_option_list("special_ability"),
          extranormal_attrs: D6System.extranormal_attributes == {} ? [] : D6System.extranormal_attributes,

          specials_difficulty: Global.read_config("d6system","specials_difficulty"),
          max_attr_dice: Global.read_config("d6system","max_attr_dice"),
          max_skill_dice: Global.read_config("d6system","max_skill_dice")
        }
      end

      def create_option_list(type)
         list = []
         new_list = []
         case type
           when "advantage"
             list = D6System.advantages
           when "disadvantage"
             list = D6System.disadvantages
           when "special_ability"
             list = D6System.special_abilities
         end
         max = Global.read_config('d6system', 'max_rank_specials')
         list.each do |m|
           option_ranks = (type == "special_ability") ? (1..max).to_a : D6System.option_ranks(m)
           cost = (type == "special_ability") ? m["cost"] : nil
           new_list << { name: m["name"], desc: m["desc"], ranks: option_ranks, cost: cost }
         end
         return new_list
      end

    end
  end
end
