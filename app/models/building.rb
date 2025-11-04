class Building < ApplicationRecord
  belongs_to :client
  has_many :custom_field_values, dependent: :destroy
  has_many :custom_fields, through: :custom_field_values

  accepts_nested_attributes_for :custom_field_values, allow_destroy: true

  validates :address, :state, :zip, presence: true
  validate :custom_fields_belong_to_client

  def as_json_with_custom_fields
    base_attributes = as_json(only: [ :id, :address, :state, :zip, :client_id ])

    custom_field_values.each_with_object(base_attributes) do |cfv, hash|
      hash[cfv.custom_field.name.parameterize.underscore] = cfv.value
    end
  end

  private

  def custom_fields_belong_to_client
    return unless client

    custom_field_values.each do |cfv|
      next if cfv.custom_field_id.blank?

      field = cfv.custom_field
      if field && field.client_id != client_id
        errors.add(:base, "Custom field #{field.name} does not belong to this client")
      end
    end
  end
end
