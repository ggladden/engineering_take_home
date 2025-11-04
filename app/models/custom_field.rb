class CustomField < ApplicationRecord
  belongs_to :client
  has_many :custom_field_values, dependent: :destroy

  enum field_type: { number: 0, freeform: 1, enum_type: 2 }

  validates :name, presence: true, uniqueness: { scope: :client_id }
  validates :field_type, presence: true
  validate :enum_options_required_for_enum_type
  validate :name_does_not_conflict_with_building_attributes

  private

  def enum_options_required_for_enum_type
    if enum_type? && (enum_options.nil? || enum_options.empty?)
      errors.add(:enum_options, "must be present for enum type fields")
    end
  end

  def name_does_not_conflict_with_building_attributes
    return if name.blank?

    parameterized_name = name.parameterize.underscore
    reserved_names = Building.column_names + [ "client_name" ]

    if reserved_names.include?(parameterized_name)
      errors.add(:name, "conflicts with building attribute '#{parameterized_name}'")
    end
  end
end
