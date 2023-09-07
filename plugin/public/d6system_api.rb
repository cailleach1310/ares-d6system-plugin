module AresMUSH
  module D6System

    class RollParams
      
     attr_accessor :ability, :dice, :pips, :linked_attr
      
      def initialize(ability, dice = 0, pips = 0, linked_attr = nil)
        self.ability = ability
        self.dice = dice
        self.pips = pips
        self.linked_attr = linked_attr
      end
    
      def to_s
        "#{self.ability} dice=#{self.dice} pips=#{self.pips} linked_attr=#{self.linked_attr}"
      end
    end


    # Makes an ability roll and returns a hash with the successes and success title.
    # Good for automated systems where you only care about the final result and don't need
    # to know the raw die roll.
    def self.one_shot_roll(char, roll_params)
      roll = D6System.roll_ability(char, roll_params)
      success_title = D6System.get_success_title(roll, roll_params.difficulty)
      
      {
        :roll_result => roll,
        :success_title => success_title
      }
    end
      
    # Rolls a raw number of dice.
    def self.one_shot_die_roll(dice, difficulty)
      roll = D6System.roll_dice(dice)
      success_title = D6System.get_success_title(roll, difficulty)

      Global.logger.info "Rolling raw dice=#{dice} result=#{roll}"
      
      {
        :roll_result => roll,
        :success_title => success_title
      }
    end

    # for advantages, disadvantages etc
    def self.simple_rating(char, ability_name)
      ability = D6System.find_ability(char, ability_name)
      if (ability)
         return ability.rating
      else
         return 0
      end
    end

   # use this on attributes and skills for the sheet
    def self.ability_rating(char, ability_name)
      ability = D6System.find_ability(char, ability_name)
      if (ability)
         return (ability.rating.split("+")[1] != '0') ? ability.rating : ability.rating.split("+")[0]
      else
         return '0D'
      end
    end
    
    # Dice they roll, including related attribute
    def self.dice_rolled(char, ability)
      D6System.dice_to_roll_for_ability(char, RollParams.new(ability))
    end    
    

    def self.build_web_char_data(char, viewer, chargen)
      builder = WebAbilityListBuilder.new
      builder.build(char, viewer, chargen)
    end

    def self.build_web_chargen_info()
      builder = WebChargenInfoBuilder.new
      builder.build()
    end

    def self.web_abilities(char)
      abilities = []
      [ char.d6attributes, char.d6skills, char.d6specializations ].each do |list|
         list.each do |a|
           abilities << a.name
         end
      end
     return abilities
    end

  end
end
