module AresMUSH
  module D6System
    class WoundsTemplate < ErbTemplateRenderer
       
      attr_accessor :wounded_chars
      
      def initialize(wounded_chars)
        self.wounded_chars = wounded_chars
        super File.dirname(__FILE__) + "/wounds.erb"
      end
      
      def fields
        Global.read_config("d6system", "wounds_fields")
      end
      
      def marque_header
        Global.read_config("d6system", "wounds_header")
      end
      
      def chars_by_handle
        self.wounded_chars.sort_by{ |c| c.name }
      end

      def show_field(char, field_config)
        field = field_config["field"]
        value = field_config["value"]
        width = field_config["width"]
        
        field_eval = D6System.general_field(char, field, value)
        left(field_eval, width)
      end
      
      def show_title(field_config)
        title = field_config["title"]
        width = field_config["width"]
        
        left(title, width)
      end
    end 
  end
end
