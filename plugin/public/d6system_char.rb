module AresMUSH
  class Character
    collection :d6attributes, "AresMUSH::D6Attribute"
    collection :d6skills, "AresMUSH::D6Skill"
    collection :d6advantages, "AresMUSH::D6Advantage"
    collection :d6disadvantages, "AresMUSH::D6Disadvantage"
    collection :d6specials, "AresMUSH::D6SpecialAbility"
    collection :d6specializations, "AresMUSH::D6Specialization"
    attribute :fate_points, :type => DataType::Integer, :default => 3
    attribute :char_points, :type => DataType::Integer, :default => 1
    attribute :body_points, :type => DataType::Integer, :default => 0

    before_delete :delete_abilities
    
    def delete_abilities
      [ self.d6attributes, self.d6skills, self.d6advantages, self.d6disadvantages, self.d6specials, self.d6specializations ].each do |list|
        list.each do |a|
          a.delete
        end
      end
    end

    def award_fate(amount)
      D6System.modify_fate(self, amount)
    end
    
    def spend_fate(amount)
      D6System.modify_fate(self, -amount)
    end

    def award_cp(amount)
      D6System.modify_cp(self, amount)
    end

    def spend_cp(amount)
      D6System.modify_cp(self, -amount)
    end

  end
end
