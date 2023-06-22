module AresMUSH
  module D6System
    
    def self.print_dice(dice)
      wild_dice_str = dice[0].map { |d| d = 6 ? "%xg#{d}%xn" : "d"}.join(" ")
      roll_str = "(" + wild_dice_str + ")"
      if (dice[1] != [])
         normal_dice_str = dice[1].join(" ")
         roll_str = roll_str + " (" + normal_dice_str + ")"
      end
      return roll_str  
    end

    def self.opposed_result_title(name1, successes1, name2, successes2)
      delta = successes1 - successes2
      
      if (successes1 <=0 && successes2 <= 0)
        return t('d6system.opposed_both_fail')
      end
      
      case delta
      when 11..99
        return t('d6system.opposed_crushing_victory', :name => name1)
      when 3..10
        return t('d6system.opposed_victory', :name => name1)
      when 1..2
        return t('d6system.opposed_marginal_victory', :name => name1)
      when 0
        return t('d6system.opposed_draw')
      when -2..-1
        return t('d6system.opposed_marginal_victory', :name => name2)
      when -10..-3
        return t('d6system.opposed_victory', :name => name2)
      when -99..-11
        return t('d6system.opposed_crushing_victory', :name => name2)
      else
        raise "Unexpected opposed roll result: #{successes1} #{successes2}"
      end
    end
        
    
    def self.get_success_title(success_level)
      case success_level
      when -1
        t('d6system.embarrassing_failure')
      when 0
        t('d6system.failure')
      when 1, 2, 3
        t('d6system.success')
      when 4
        t('d6system.good_success')
      when 5
        t('d6system.exceptional_success')
      when 6..99
        t('d6system.amazing_success')
      else
        raise "Unexpected roll result: #{success_level}"
      end
    end
    
  end
end
