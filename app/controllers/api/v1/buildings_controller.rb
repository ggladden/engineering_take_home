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

      private

      def building_params
        params.require(:building).permit(
          :client_id,
          :address,
          :state,
          :zip,
          custom_field_values_attributes: [ :custom_field_id, :value ]
        )
      end
    end
  end
end
