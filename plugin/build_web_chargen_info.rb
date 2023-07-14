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
          advantages: D6System.advantages,
          disadvantages: D6System.disadvantages,
          special_abilities: D6System.special_abilities
        }
      end
    end
  end
end
