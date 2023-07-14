module AresMUSH
  class D6SpecialAbility < Ohm::Model
    include ObjectModel
    
    reference :character, "AresMUSH::Character"
    attribute :name
    attribute :rank, :type => DataType::Integer, :default => 1
    attribute :details
    
    index :name
    
  end
end
