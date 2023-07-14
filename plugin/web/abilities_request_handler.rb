module AresMUSH
  module D6System
    class AbilitiesRequestHandler
      def handle(request)
        attrs = D6System.attributes.map { |a| { 
          name: a['name'].titleize,
          desc: a['desc']
        } }

        skills = D6System.skills.select { |s| !s['linked_attr'].include?("Extranormal") }.map { |a| {
          name: a['name'].titleize,
          linked_attr: a['linked_attr'],
          desc: a['desc']
        }}

        extranormal_skills = D6System.skills.select { |s| s['linked_attr'].include?("Extranormal") }.map { |a| {
          name: a['name'].titleize,
          linked_attr: a['linked_attr'],
          desc: a['desc']
        }}

        advantages = D6System.advantages.sort_by { |a| a['name'] }.map { |a| {
          name: a['name'].titleize,
          desc: a['desc'],
          max_rank: a['max_rank']
        }}

        disadvantages = D6System.disadvantages.sort_by { |a| a['name'] }.map { |a| {
          name: a['name'].titleize,
          desc: a['desc'],
          ranks: a['ranks']
        }}

        special_abilities = D6System.special_abilities.sort_by { |a| a['name'] }.map { |a| {
          name: a['name'].titleize,
          desc: a['desc'],
          cost: a['cost']
        }}
        
        {
          attrs_blurb: Website.format_markdown_for_html(D6System.attributes_blurb),
          skills_blurb: Website.format_markdown_for_html(D6System.skills_blurb),
          advantages_blurb: Website.format_markdown_for_html(D6System.advantages_blurb),
          disadvantages_blurb: Website.format_markdown_for_html(D6System.disadvantages_blurb),
          special_abilities_blurb: Website.format_markdown_for_html(D6System.specials_blurb),
          
          attrs: attrs,
          skills: skills,
          extranormal_skills: extranormal_skills,
          advantages: advantages,
          disadvantages: disadvantages,
          special_abilities: special_abilities
        } 
      end
    end
  end
end
