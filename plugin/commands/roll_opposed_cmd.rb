module AresMUSH

  module D6System
    class OpposedRollCmd
      include CommandHandler
      
      attr_accessor :name1, :name2, :roll_str1, :roll_str2, :private_roll

      def parse_args
        args = cmd.parse_args( /(?<name1>[^\/]+)\/(?<str1>.+) vs (?<name2>[^\/]+)?\/?(?<str2>.+)/ )
        self.roll_str1 = titlecase_arg(args.str1)
        self.roll_str2 = titlecase_arg(args.str2)
        self.name1 = titlecase_arg(args.name1)
        self.name2 = titlecase_arg(args.name2)
        self.private_roll = cmd.switch_is?("private")
      end

      def required_args
        [ self.name1, self.roll_str1, self.roll_str2 ]
      end
      
      def handle
        
        result = ClassTargetFinder.find(self.name1, Character, enactor)
        model1 = result.target
        if (!model1 && !D6System.valid_roll_str(self.roll_str1))
          client.emit_failure t('d6system.numbers_only_for_npc_skills')
          return
        end
                                
        if (self.name2)
          result = ClassTargetFinder.find(self.name2, Character, enactor)
          model2 = result.target
          self.name2 = !model2 ? self.name2 : model2.name
        end
                                
        if (!model2 && !D6System.valid_roll_str(self.roll_str2))
          client.emit_failure t('d6system.numbers_only_for_npc_skills')
          return
        end

        if !model1
          die_result1 = D6System.parse_and_roll(enactor, self.roll_str1)
          total1 = D6System.get_result(die_result1[:dice_roll]) + D6System.get_pips(self.roll_str1)
        else
          die_result1 = D6System.parse_and_roll(model1, self.roll_str1)
          total1 = D6System.get_result(die_result1[:dice_roll]) + die_result1[:roll_modifiers]
        end

        if !model2
          die_result2 = D6System.parse_and_roll(enactor, self.roll_str2)
          total2 = D6System.get_result(die_result1[:dice_roll]) + D6System.get_pips(self.roll_str2)
        else
          die_result2 = D6System.parse_and_roll(model2, self.roll_str2)
          total2 = D6System.get_result(die_result2[:dice_roll]) + die_result2[:roll_modifiers]
        end
          
#        die_result1 = D6System.parse_and_roll(model1, self.roll_str1)
#        die_result2 = D6System.parse_and_roll(model2, self.roll_str2)
          
        if (!die_result1 || !die_result2)
          client.emit_failure t('d6system.unknown_roll_params')
          return
        end
          
#        total1 = D6System.get_result(die_result1[:dice_roll]) + die_result1[:roll_modifiers]
#        total2 = D6System.get_result(die_result2[:dice_roll]) + die_result2[:roll_modifiers]
        success_title1 = D6System.get_success_title(die_result1[:dice_roll])
        success_title2 = D6System.get_success_title(die_result2[:dice_roll])

        results = D6System.opposed_result_title(self.name1, total1, self.name2, total2)
          
        message = t('d6system.opposed_roll_result',
           :name1 => !model1 ? t('d6system.npc', :name => self.name1) : model1.name,
           :name2 => !model2 ? t('d6system.npc', :name => self.name2) : model2.name,
           :roll1 => self.roll_str1,
           :roll2 => self.roll_str2,
           :dice1 => D6System.print_dice(die_result1[:dice_roll]),
           :dice2 => D6System.print_dice(die_result2[:dice_roll]),
           :total1 => total1,
           :total2 => total2,
           :success1 => success_title1,
           :success2 => success_title2,
           :result => results)

        D6System.emit_results message, client, enactor_room, self.private_roll
      end
    end
  end
end
