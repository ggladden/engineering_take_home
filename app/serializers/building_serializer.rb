class BuildingSerializer
  def initialize(building, options = {})
    @building = building
    @include_all_client_fields = options[:include_all_client_fields] || false
  end

  def as_json
    base_attributes = {
      id: @building.id,
      address: @building.address,
      state: @building.state,
      zip: @building.zip,
      client_name: @building.client.name
    }

    if @include_all_client_fields
      add_all_client_custom_fields(base_attributes)
    else
      add_building_custom_fields(base_attributes)
    end

    base_attributes
  end

  private

  def add_all_client_custom_fields(hash)
    custom_field_map = @building.custom_field_values.index_by(&:custom_field_id)

    @building.client.custom_fields.each do |field|
      key = field.name.parameterize.underscore
      cfv = custom_field_map[field.id]
      hash[key] = cfv ? cfv.value : ""
    end
  end

  def add_building_custom_fields(hash)
    @building.custom_field_values.each do |cfv|
      key = cfv.custom_field.name.parameterize.underscore
      hash[key] = cfv.value
    end
  end
end
