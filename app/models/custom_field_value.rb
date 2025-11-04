class CustomFieldValue < ApplicationRecord
  belongs_to :building
  belongs_to :custom_field

  validate :value_matches_field_type

  private

  def value_matches_field_type
    return if value.blank? # Allow empty values

    case custom_field.field_type
    when "number"
      validate_number_field
    when "freeform"
      # freeform accepts any string value
    when "enum_type"
      validate_enum_field
    end
  end

  def validate_number_field
    unless value.match?(/\A-?\d+\.?\d*\z/)
      errors.add(:value, "must be a valid number")
    end
  end

  def validate_enum_field
    unless custom_field.enum_options.include?(value)
      errors.add(:value, "must be one of: #{custom_field.enum_options.join(', ')}")
    end
  end
end
