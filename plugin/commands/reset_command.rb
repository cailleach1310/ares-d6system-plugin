module AresMUSH
  module D6System
    class ResetCmd
      include CommandHandler

      def check_chargen_locked
        Chargen.check_chargen_locked(enactor)
      end

      def handle
        D6System.reset_char(enactor)        
        client.emit_success t('d6system.reset_complete')
      end
    end
  end
end
