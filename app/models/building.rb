class Building < ApplicationRecord
  belongs_to :client
  has_many :custom_field_values, dependent: :destroy
  has_many :custom_fields, through: :custom_field_values

  validates :address, :state, :zip, presence: true
end
