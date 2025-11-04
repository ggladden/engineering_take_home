class Client < ApplicationRecord
  has_many :buildings, dependent: :destroy
  has_many :custom_fields, dependent: :destroy

  validates :name, presence: true
end
