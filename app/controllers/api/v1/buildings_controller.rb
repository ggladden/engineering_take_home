module Api
  module V1
    class BuildingsController < ApplicationController
      skip_before_action :verify_authenticity_token

      def create
        building = Building.new(building_params)

        if building.save
          building = Building.includes(:client, custom_field_values: :custom_field).find(building.id)

          render json: {
            status: "success",
            building: BuildingSerializer.new(building).as_json
          }, status: :created
        else
          render json: {
            status: "error",
            errors: building.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def update
        building = Building.find(params[:id])

        if building.update(building_params)
          building = Building.includes(:client, custom_field_values: :custom_field).find(building.id)

          render json: {
            status: "success",
            building: BuildingSerializer.new(building).as_json
          }, status: :ok
        else
          render json: {
            status: "error",
            errors: building.errors.full_messages
          }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound
        render json: {
          status: "error",
          errors: [ "Building not found" ]
        }, status: :not_found
      end

      def index
        page = params[:page].to_i
        page = 1 if page < 1
        per_page = params[:per_page].to_i
        per_page = 25 if per_page < 1

        buildings = Building
          .includes(:client, client: :custom_fields, custom_field_values: :custom_field)
          .limit(per_page)
          .offset((page - 1) * per_page)

        total_count = Building.count
        total_pages = (total_count.to_f / per_page).ceil

        render json: {
          status: "success",
          buildings: buildings.map { |b| BuildingSerializer.new(b, include_all_client_fields: true).as_json },
          pagination: {
            current_page: page,
            per_page: per_page,
            total_pages: total_pages,
            total_count: total_count
          }
        }, status: :ok
      end

      private

      def building_params
        params.require(:building).permit(
          :client_id,
          :address,
          :state,
          :zip,
          custom_field_values_attributes: [ :id, :custom_field_id, :value, :_destroy ]
        )
      end
    end
  end
end
