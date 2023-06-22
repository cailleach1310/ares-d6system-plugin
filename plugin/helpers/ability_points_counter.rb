module AresMUSH
  module D6System

      def self.total_points(char)
        return self.points_on_attrs(char) + self.points_on_skills(char) + 
           self.points_on_advantages(char) - self.points_on_disadvantages(char)
      end

      def self.calculate_dice(list)
        dice = list.inject(0) { |count, a| count + a.dice } 
        pips_total = list.inject(0) { |count, a| count + a.pips } 
        extra_dice = pips_total / 3
        if ((pips_total % 3) != 0)
           extra_dice = extra_dice + 1
        end
        return dice + extra_dice
      end

      def self.points_on_attrs(char)
        return calculate_dice(char.d6attributes) * 4
      end

      def self.points_on_skills(char)
        return calculate_dice(char.d6skills)
      end
      
      def self.points_on_advantages(char)
        char.d6advantages.inject(0) { |count, a| count + a.rating }
      end

      def self.points_on_disadvantages(char)
        char.d6disadvantages.inject(0) { |count, a| count + a.rating }
      end

  end
end 
