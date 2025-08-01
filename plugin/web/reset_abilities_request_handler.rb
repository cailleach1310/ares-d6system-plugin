module AresMUSH
  module D6System
    class ResetAbilitiesRequestHandler
      def handle(request)
         char = Character.find_one_by_name request.args['name']
         if !char
             return { error: "Invalid char name" }
         else 
             D6System.reset_char(char)        
         end
         {
             name: char.name 
         }
      end
    end
  end
end
