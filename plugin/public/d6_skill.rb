module AresMUSH
  class D6Skill < Ohm::Model
    include ObjectModel
    
    reference :character, "AresMUSH::Character"
    attribute :name
    attribute :rating, :default => '0D+0'
    
    index :name
    
    def print_rating
      case rating
      when 0
        return ""
      when 1
        return "%xg@%xn"
      when 2
        return "%xg@%xy@%xn"
      when 3
        return "%xg@%xy@%xr@%xn"
      when 4
        return "%xg@%xy@%xr@%xb@%xn"
      when 5
        return "%xg@%xy@%xr@%xb@%xg@%xn"
       end
    end

  end
end
