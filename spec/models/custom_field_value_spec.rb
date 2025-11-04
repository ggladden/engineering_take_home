require 'rails_helper'

RSpec.describe CustomFieldValue, type: :model do
  let(:building) { create(:building) }

  describe 'validations' do
    describe 'value_matches_field_type' do
      context 'with number field' do
        let(:number_field) { create(:custom_field, :number) }

        it 'is valid with integer value' do
          value = build(:custom_field_value, custom_field: number_field, building: building, value: "42")
          expect(value).to be_valid
        end

        it 'is valid with decimal value' do
          value = build(:custom_field_value, custom_field: number_field, building: building, value: "2.5")
          expect(value).to be_valid
        end

        it 'is valid with negative value' do
          value = build(:custom_field_value, custom_field: number_field, building: building, value: "-10")
          expect(value).to be_valid
        end

        it 'is invalid with non-numeric value' do
          value = build(:custom_field_value, custom_field: number_field, building: building, value: "abc")
          expect(value).not_to be_valid
          expect(value.errors[:value]).to include("must be a valid number")
        end

        it 'is invalid with mixed alphanumeric value' do
          value = build(:custom_field_value, custom_field: number_field, building: building, value: "12abc")
          expect(value).not_to be_valid
        end
      end

      context 'with enum field' do
        let(:enum_field) { create(:custom_field, :enum_type, enum_options: ["Red", "Blue", "Green"]) }

        it 'is valid with allowed option' do
          value = build(:custom_field_value, custom_field: enum_field, building: building, value: "Red")
          expect(value).to be_valid
        end

        it 'is invalid with non-allowed option' do
          value = build(:custom_field_value, custom_field: enum_field, building: building, value: "Yellow")
          expect(value).not_to be_valid
          expect(value.errors[:value]).to include("must be one of: Red, Blue, Green")
        end
      end

      context 'with freeform field' do
        let(:freeform_field) { create(:custom_field, :freeform) }

        it 'is valid with any string value' do
          value = build(:custom_field_value, custom_field: freeform_field, building: building, value: "Any text here!")
          expect(value).to be_valid
        end
      end

      context 'with blank value' do
        it 'is valid for number field' do
          number_field = create(:custom_field, :number)
          value = build(:custom_field_value, custom_field: number_field, building: building, value: "")
          expect(value).to be_valid
        end

        it 'is valid for enum field' do
          enum_field = create(:custom_field, :enum_type)
          value = build(:custom_field_value, custom_field: enum_field, building: building, value: "")
          expect(value).to be_valid
        end
      end
    end
  end
end
