module AresMUSH
  class Character
    collection :d6attributes, "AresMUSH::D6Attribute"
    collection :d6skills, "AresMUSH::D6Skill"
    collection :d6advantages, "AresMUSH::D6Advantage"
    collection :d6disadvantages, "AresMUSH::D6Disadvantage"
    attribute :fate_points, :type => DataType::Integer, :default => 0
    attribute :xp, :type => DataType::Integer, :default => 0

    before_delete :delete_abilities
    
    def delete_abilities
      [ self.d6attributes, self.d6skills, self.d6advantages, self.d6disadvantages ].each do |list|
        list.each do |a|
          a.delete
        end
      end
    end

  end
end
