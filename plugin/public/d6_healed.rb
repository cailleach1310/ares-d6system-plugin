module AresMUSH
  class D6Healed < Ohm::Model
    include ObjectModel
    
    reference :character, "AresMUSH::Character"
    attribute :name
    attribute :healed_at
    
    index :name
    
  end
end
