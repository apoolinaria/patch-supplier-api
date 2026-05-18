class Project < ApplicationRecord
  has_many :offsets, dependent: :destroy
  has_many :payouts, dependent: :destroy

  validates :name, presence: true
  validates :api_key, presence: true, uniqueness: true

  before_create :generate_api_key

  private

  def generate_api_key
    self.api_key = "key_test_#{SecureRandom.hex(16)}"
  end
end
