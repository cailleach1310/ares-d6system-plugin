module AresMUSH
  class D6Specialization < Ohm::Model
    include ObjectModel
    include LearnableAbility
    
    reference :character, "AresMUSH::Character"
    attribute :name
    attribute :skill
    attribute :rating, :default => '0D+0'
    
    index :name
    
  end
end
