require 'active_model/serializer'

module Spree
  module Wombat
    class PetSerializer < ActiveModel::Serializer
      attributes :id, :species, :gender, :size, :weight, :age, :breed, :name,
                 :birthdate, :environment, :condition, :castrated, :user_id
    end
  end
end
