module AresMUSH
  module D6System

    def self.app_review(char)
      overview = D6System.points_overview(char)
      msg = D6System.ability_points_review(char)
      if (msg == "")
         msg = t('chargen.ok')
      else
         msg = "%xh%xr< See issues below >%xn%r" + msg
      end
      return Chargen.format_review_status "Checking D6 abilities.", msg + "%r%r" + overview
    end

    def self.abilities_not_set(char)
       normal_attributes = D6System.attributes.size - D6System.extranormal_attributes.size
       return char.d6attributes.empty? || (D6System.dice_spent(char.d6attributes) < normal_attributes)
    end

    def self.points_overview(char)
       msg = ""
       msg = msg + "Spent points:"
       msg = msg + "%r* Attributes: ".ljust(23," ") + (dice_spent(char.d6attributes)*4).to_s.rjust(3," ")
       msg = msg + "%r* Skills: ".ljust(23," ") + dice_spent(char.d6skills).to_s.rjust(3," ")
       msg = msg + "%r* Specializations: ".ljust(23," ") + (dice_spent(char.d6specializations)/3.to_f).ceil.to_s.rjust(3," ")
       msg = msg + "%r* Advantages: ".ljust(23," ") + count_points(char.d6advantages).to_s.rjust(3," ")
       msg = msg + "%r* Disadvantages: ".ljust(23," ") + (count_points(char.d6disadvantages)* (-1)).to_s.rjust(3," ")
       msg = msg + "%r* Special Abilities: ".ljust(23," ") + count_specials_points(char).to_s.rjust(3," ")
       msg = msg + "%r* Total: ".ljust(23," ") + spent_total(char).to_s.rjust(3," ")
       return msg
    end

    def self.ability_points_review(char)
       msg = ""
       if abilities_not_set(char)
          msg = msg + "%r" + t('d6system.abilities_not_set')
       end
       # check points_max
       cp = Global.read_config("d6system","cg_creation_points")
       if (spent_total(char) > cp)
          msg = msg + "%r" + t('d6system.too_many_points_spent', :total => spent_total(char), :max => cp )
       end
       max_attr_dice = Global.read_config("d6system","max_attr_cg_dice")
       if (dice_spent(char.d6attributes) > max_attr_dice)
          msg = msg + "%r" + t('d6system.too_many_attr_dice', :total => dice_spent(char.d6attributes), :max => max_attr_dice )
       end
       max_skill_dice = Global.read_config("d6system","max_skill_cg_dice")
       if (dice_spent(char.d6skills) > max_skill_dice)
          msg = msg + "%r" + t('d6system.too_many_skill_dice', :total => dice_spent(char.d6skills), :max => max_skill_dice )
       end
       return msg
     end

    def self.spent_total(char)
      attr_total_dice = dice_spent(char.d6attributes)
      skill_total_dice = dice_spent(char.d6skills)
      spec_total_dice = dice_spent(char.d6specializations)
      adv_total = count_points(char.d6advantages)
      dis_total = count_points(char.d6disadvantages)
      spec_abilities_total = count_specials_points(char)
      sum = attr_total_dice * 4 + skill_total_dice + (spec_total_dice/3.to_f).ceil + adv_total - dis_total + spec_abilities_total
      return sum
    end

    def self.dice_spent(list)
      total_dice = '0D+0'
      list.each do |a|
        total_dice = D6System.add_dice(total_dice, a.rating, 0)
      end
      dice_spent = (D6System.get_pips(total_dice) > 0) ? D6System.get_dice(total_dice) + 1 : D6System.get_dice(total_dice)
    end

    def self.count_points(list)
      total = 0
      list.each do |l|
        total = total + l.rank
      end
      return total
    end

    def self.count_specials_points(char)
      total = 0
      char.d6specials.each do |l|
        special = D6System.special_abilities.find { |s| (s['name'] == l.name) }
        difficulty = Global.read_config("d6system","specials_difficulty")
        factor = (difficulty == "cost") ? special['cost'] : difficulty
        total = total + special['cost'] + ((l.rank - 1) * factor)
      end
      return total
    end

  end
end
