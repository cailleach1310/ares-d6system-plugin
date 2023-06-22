module AresMUSH
  class D6Disadvantage < Ohm::Model
    include ObjectModel
#    include LearnableAbility
    
    reference :character, "AresMUSH::Character"
    attribute :name
    attribute :rank, :type => DataType::Integer, :default => 1
    
    index :name
    
  end
end
