require 'rails_helper'

RSpec.describe "Api::V1::Buildings", type: :request do
  describe "POST /api/v1/buildings" do
    let(:client) { create(:client) }
    let(:number_field) { create(:custom_field, :number, client: client, name: "Bedrooms") }
    let(:enum_field) { create(:custom_field, :enum_type, client: client, name: "Roof Type", enum_options: ["Shingle", "Tile"]) }

    context "with valid parameters" do
      it "creates a building with custom field values" do
        params = {
          building: {
            client_id: client.id,
            address: "123 Test St",
            state: "NY",
            zip: "10001",
            custom_field_values_attributes: [
              { custom_field_id: number_field.id, value: "3" },
              { custom_field_id: enum_field.id, value: "Shingle" }
            ]
          }
        }

        expect {
          post "/api/v1/buildings", params: params, as: :json
        }.to change(Building, :count).by(1)
          .and change(CustomFieldValue, :count).by(2)

        expect(response).to have_http_status(:created)

        json = JSON.parse(response.body)
        expect(json["status"]).to eq("success")
        expect(json["building"]["address"]).to eq("123 Test St")
        expect(json["building"]["bedrooms"]).to eq("3")
        expect(json["building"]["roof_type"]).to eq("Shingle")

        building = Building.last
        expect(building.custom_field_values.find_by(custom_field: number_field).value).to eq("3")
        expect(building.custom_field_values.find_by(custom_field: enum_field).value).to eq("Shingle")
      end

      it "allows empty custom field values" do
        params = {
          building: {
            client_id: client.id,
            address: "456 Test Ave",
            state: "CA",
            zip: "90210",
            custom_field_values_attributes: [
              { custom_field_id: number_field.id, value: "" }
            ]
          }
        }

        post "/api/v1/buildings", params: params, as: :json

        expect(response).to have_http_status(:created)

        building = Building.last
        expect(building.custom_field_values.find_by(custom_field: number_field).value).to eq("")
      end
    end

    context "with invalid parameters" do
      it "returns error when custom field does not belong to client" do
        other_client = create(:client)
        other_field = create(:custom_field, :number, client: other_client, name: "Other Field")

        params = {
          building: {
            client_id: client.id,
            address: "789 Test Blvd",
            state: "TX",
            zip: "75001",
            custom_field_values_attributes: [
              { custom_field_id: other_field.id, value: "5" }
            ]
          }
        }

        post "/api/v1/buildings", params: params, as: :json

        expect(response).to have_http_status(:unprocessable_entity)

        json = JSON.parse(response.body)
        expect(json["status"]).to eq("error")
        expect(json["errors"]).to be_present
      end

      it "returns error when building validation fails" do
        params = {
          building: {
            client_id: client.id,
            address: "",
            state: "NY",
            zip: "10001"
          }
        }

        post "/api/v1/buildings", params: params, as: :json

        expect(response).to have_http_status(:unprocessable_entity)

        json = JSON.parse(response.body)
        expect(json["status"]).to eq("error")
      end
    end
  end

  describe "PATCH /api/v1/buildings/:id" do
    let(:client) { create(:client) }
    let(:building) { create(:building, client: client, address: "Original St", state: "NY", zip: "10001") }
    let(:number_field) { create(:custom_field, :number, client: client, name: "Bedrooms") }
    let(:enum_field) { create(:custom_field, :enum_type, client: client, name: "Roof Type", enum_options: ["Shingle", "Tile"]) }

    context "with valid parameters" do
      it "updates building attributes" do
        params = {
          building: {
            address: "Updated St",
            state: "CA",
            zip: "90210"
          }
        }

        patch "/api/v1/buildings/#{building.id}", params: params, as: :json

        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        expect(json["status"]).to eq("success")
        expect(json["building"]["address"]).to eq("Updated St")
        expect(json["building"]["state"]).to eq("CA")
        expect(json["building"]["zip"]).to eq("90210")

        building.reload
        expect(building.address).to eq("Updated St")
      end

      it "updates existing custom field values" do
        cfv = create(:custom_field_value, building: building, custom_field: number_field, value: "3")

        params = {
          building: {
            custom_field_values_attributes: [
              { id: cfv.id, custom_field_id: number_field.id, value: "5" }
            ]
          }
        }

        patch "/api/v1/buildings/#{building.id}", params: params, as: :json

        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        expect(json["building"]["bedrooms"]).to eq("5")

        cfv.reload
        expect(cfv.value).to eq("5")
      end

      it "adds new custom field values" do
        params = {
          building: {
            custom_field_values_attributes: [
              { custom_field_id: number_field.id, value: "4" }
            ]
          }
        }

        expect {
          patch "/api/v1/buildings/#{building.id}", params: params, as: :json
        }.to change(building.custom_field_values, :count).by(1)

        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        expect(json["building"]["bedrooms"]).to eq("4")
      end

      it "removes custom field values" do
        cfv = create(:custom_field_value, building: building, custom_field: number_field, value: "3")

        params = {
          building: {
            custom_field_values_attributes: [
              { id: cfv.id, _destroy: true }
            ]
          }
        }

        expect {
          patch "/api/v1/buildings/#{building.id}", params: params, as: :json
        }.to change(building.custom_field_values, :count).by(-1)

        expect(response).to have_http_status(:ok)
        expect(CustomFieldValue.exists?(cfv.id)).to be false
      end
    end

    context "with invalid parameters" do
      it "returns error when custom field does not belong to client" do
        other_client = create(:client)
        other_field = create(:custom_field, :number, client: other_client, name: "Other Field")

        params = {
          building: {
            custom_field_values_attributes: [
              { custom_field_id: other_field.id, value: "5" }
            ]
          }
        }

        patch "/api/v1/buildings/#{building.id}", params: params, as: :json

        expect(response).to have_http_status(:unprocessable_entity)

        json = JSON.parse(response.body)
        expect(json["status"]).to eq("error")
        expect(json["errors"]).to be_present
      end

      it "returns error when building not found" do
        params = {
          building: {
            address: "Updated St"
          }
        }

        patch "/api/v1/buildings/99999", params: params, as: :json

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "GET /api/v1/buildings" do
    let(:client1) { create(:client, name: "Client One") }
    let(:client2) { create(:client, name: "Client Two") }

    let!(:field1_client1) { create(:custom_field, :number, client: client1, name: "Bedrooms") }
    let!(:field2_client1) { create(:custom_field, :freeform, client: client1, name: "Color") }

    let!(:building1) do
      building = create(:building, client: client1, address: "123 Main St", state: "NY", zip: "10001")
      create(:custom_field_value, building: building, custom_field: field1_client1, value: "3")
      building
    end

    let!(:building2) do
      building = create(:building, client: client1, address: "456 Oak Ave", state: "CA", zip: "90210")
      create(:custom_field_value, building: building, custom_field: field1_client1, value: "2")
      create(:custom_field_value, building: building, custom_field: field2_client1, value: "Blue")
      building
    end

    let!(:building3) { create(:building, client: client2, address: "789 Elm Rd", state: "TX", zip: "75001") }

    it "returns all buildings with pagination" do
      get "/api/v1/buildings", params: { page: 1, per_page: 2 }, as: :json

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json["status"]).to eq("success")
      expect(json["buildings"].length).to eq(2)
      expect(json["pagination"]["current_page"]).to eq(1)
      expect(json["pagination"]["total_pages"]).to eq(2)
      expect(json["pagination"]["total_count"]).to eq(3)
    end

    it "returns second page of results" do
      get "/api/v1/buildings", params: { page: 2, per_page: 2 }, as: :json

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json["buildings"].length).to eq(1)
      expect(json["pagination"]["current_page"]).to eq(2)
    end

    it "includes client_name and all custom fields for each building" do
      get "/api/v1/buildings", as: :json

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      building1_json = json["buildings"].find { |b| b["id"] == building1.id }

      expect(building1_json["client_name"]).to eq("Client One")
      expect(building1_json["address"]).to eq("123 Main St")
      expect(building1_json["bedrooms"]).to eq("3")
      expect(building1_json["color"]).to eq("")
    end

    it "returns empty array when no buildings exist" do
      Building.destroy_all

      get "/api/v1/buildings", as: :json

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json["buildings"]).to eq([])
      expect(json["pagination"]["total_count"]).to eq(0)
    end
  end
end
