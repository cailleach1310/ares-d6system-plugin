module AresMUSH
  module D6System
    class AbilityPageTemplate < ErbTemplateRenderer


      attr_accessor :data
      
      def initialize(file, data)
        @data = data
        super File.dirname(__FILE__) + file
      end
      
      def page_footer
        footer = t('pages.page_x_of_y', :x => @data[:page], :y => @data[:num_pages])
        template = PageFooterTemplate.new(footer)
        template.render
      end
      
      def attr_blurb
        D6System.attributes_blurb
      end
      
      def skills_blurb
        D6System.skills_blurb
      end
      
      def advantages_blurb
        D6System.advantages_blurb
      end
      
      def disadvantages_blurb
        D6System.disadvantages_blurb
      end

      def specials_blurb
        D6System.specials_blurb
      end

    end
  end
end
