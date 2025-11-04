class CustomField < ApplicationRecord
  belongs_to :client
  has_many :custom_field_values, dependent: :destroy

  enum field_type: { number: 0, freeform: 1, enum_type: 2 }

  validates :name, presence: true, uniqueness: { scope: :client_id }
  validates :field_type, presence: true
  validate :enum_options_required_for_enum_type

  private

  def enum_options_required_for_enum_type
    if enum_type? && (enum_options.nil? || enum_options.empty?)
      errors.add(:enum_options, "must be present for enum type fields")
    end
  end
end
