require 'rails_helper'

RSpec.describe CustomField, type: :model do
  describe 'validations' do
    describe 'enum_options_required_for_enum_type' do
      it 'is valid when enum type has options' do
        field = build(:custom_field, :enum_type)
        expect(field).to be_valid
      end

      it 'is invalid when enum type has no options' do
        field = build(:custom_field, field_type: :enum_type, enum_options: [])
        expect(field).not_to be_valid
        expect(field.errors[:enum_options]).to include("must be present for enum type fields")
      end

      it 'is valid when number type has no options' do
        field = build(:custom_field, :number)
        expect(field).to be_valid
      end

      it 'is valid when freeform type has no options' do
        field = build(:custom_field, :freeform)
        expect(field).to be_valid
      end
    end

    describe 'name uniqueness' do
      let(:client) { create(:client) }

      it 'is invalid when name is duplicate for same client' do
        create(:custom_field, :number, name: 'Bathrooms', client: client)
        duplicate_field = build(:custom_field, :number, name: 'Bathrooms', client: client)

        expect(duplicate_field).not_to be_valid
        expect(duplicate_field.errors[:name]).to include("has already been taken")
      end

      it 'is valid when same name exists for different client' do
        other_client = create(:client)
        create(:custom_field, :number, name: 'Bathrooms', client: client)
        field_for_other_client = build(:custom_field, :number, name: 'Bathrooms', client: other_client)

        expect(field_for_other_client).to be_valid
      end
    end

    describe 'name conflict with building attributes' do
      let(:client) { create(:client) }

      it 'is invalid when name conflicts with building column' do
        field = build(:custom_field, :number, name: 'Address', client: client)

        expect(field).not_to be_valid
        expect(field.errors[:name]).to include("conflicts with building attribute 'address'")
      end

      it 'is invalid when parameterized name conflicts' do
        field = build(:custom_field, :number, name: 'Client ID', client: client)

        expect(field).not_to be_valid
        expect(field.errors[:name]).to include("conflicts with building attribute 'client_id'")
      end

      it 'is valid when name does not conflict' do
        field = build(:custom_field, :number, name: 'Bathrooms', client: client)

        expect(field).to be_valid
      end
    end
  end
end
