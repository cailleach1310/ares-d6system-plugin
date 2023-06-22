module AresMUSH
  module D6System
    class WebChargenInfoBuilder

      def build()
        {
          attrs_blurb: Website.format_markdown_for_html(D6System.attributes_blurb),
          skills_blurb: Website.format_markdown_for_html(D6System.skills_blurb),
          advantages_blurb: Website.format_markdown_for_html(D6System.advantages_blurb),
          disadvantages_blurb: Website.format_markdown_for_html(D6System.disadvantages_blurb),

          skillnames: D6System.skill_names,
        }
      end
    end
  end
end
