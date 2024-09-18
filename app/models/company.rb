# frozen_string_literal: true

class Company < ApplicationRecord
  has_many :cars

  has_many :luxury_cars
  has_many :sports_cars
end
