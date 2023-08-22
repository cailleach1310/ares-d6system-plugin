module AresMUSH
  module D6System
    class WoundListCmd
      include CommandHandler
      
      def check_can_view
        return nil if enactor.is_admin?
        return "You are not allowed to use this command."
      end	

      def handle
        wounded_chars = D6System.wounded_chars
        template = WoundsTemplate.new wounded_chars
	client.emit template.render
      end 
    end  
  end
end
