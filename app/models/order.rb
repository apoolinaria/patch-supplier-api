class Order < ApplicationRecord
  belongs_to :offset

  validates :mass_g, presence: true, numericality: { in: 1..200_000_000 }
end
