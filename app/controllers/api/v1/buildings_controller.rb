module Api
  module V1
    class BuildingsController < ApplicationController
      skip_before_action :verify_authenticity_token

      def create
        building = Building.new(building_params)

        if building.save
          building = Building.includes(custom_field_values: :custom_field).find(building.id)

          render json: {
            status: "success",
            building: building.as_json_with_custom_fields
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
          building = Building.includes(custom_field_values: :custom_field).find(building.id)

          render json: {
            status: "success",
            building: building.as_json_with_custom_fields
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
