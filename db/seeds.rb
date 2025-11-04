# Clear existing data
CustomFieldValue.destroy_all
Building.destroy_all
CustomField.destroy_all
Client.destroy_all

# Client 1: Residential Properties
Client.create!(name: "Metropolitan Residential").tap do |client|
  bedrooms = client.custom_fields.create!(name: "Bedrooms", field_type: :number)
  roof_type = client.custom_fields.create!(name: "Roof Type", field_type: :enum_type, enum_options: [ "Shingle", "Tile", "Metal", "Flat" ])
  notes = client.custom_fields.create!(name: "Property Notes", field_type: :freeform)

  client.buildings.create!(address: "123 Main St", state: "NY", zip: "10001").tap do |building|
    building.custom_field_values.create!(custom_field: bedrooms, value: "3")
    building.custom_field_values.create!(custom_field: roof_type, value: "Shingle")
    building.custom_field_values.create!(custom_field: notes, value: "Recently renovated kitchen")
  end

  client.buildings.create!(address: "456 Oak Ave", state: "NY", zip: "10002").tap do |building|
    building.custom_field_values.create!(custom_field: bedrooms, value: "4")
    building.custom_field_values.create!(custom_field: roof_type, value: "Tile")
    building.custom_field_values.create!(custom_field: notes, value: "")
  end
end

# Client 2: Commercial Properties
Client.create!(name: "Downtown Commercial Group").tap do |client|
  sqft = client.custom_fields.create!(name: "Square Footage", field_type: :number)
  zoning = client.custom_fields.create!(name: "Zoning", field_type: :enum_type, enum_options: [ "Commercial", "Mixed-Use", "Industrial" ])
  parking = client.custom_fields.create!(name: "Parking Spaces", field_type: :number)

  client.buildings.create!(address: "789 Business Blvd", state: "CA", zip: "90210").tap do |building|
    building.custom_field_values.create!(custom_field: sqft, value: "5000")
    building.custom_field_values.create!(custom_field: zoning, value: "Commercial")
    building.custom_field_values.create!(custom_field: parking, value: "25")
  end

  client.buildings.create!(address: "321 Market St", state: "CA", zip: "90211").tap do |building|
    building.custom_field_values.create!(custom_field: sqft, value: "7500")
    building.custom_field_values.create!(custom_field: zoning, value: "Mixed-Use")
    building.custom_field_values.create!(custom_field: parking, value: "40")
  end
end

# Client 3: Historic Buildings
Client.create!(name: "Heritage Preservation Society").tap do |client|
  year = client.custom_fields.create!(name: "Year Built", field_type: :number)
  former_use = client.custom_fields.create!(name: "Former Use", field_type: :freeform)
  status = client.custom_fields.create!(name: "Landmark Status", field_type: :enum_type, enum_options: [ "National", "State", "Local", "None" ])

  client.buildings.create!(address: "100 Heritage Ln", state: "MA", zip: "02101").tap do |building|
    building.custom_field_values.create!(custom_field: year, value: "1887")
    building.custom_field_values.create!(custom_field: former_use, value: "Originally a church")
    building.custom_field_values.create!(custom_field: status, value: "National")
  end

  client.buildings.create!(address: "250 Old Town Rd", state: "MA", zip: "02102").tap do |building|
    building.custom_field_values.create!(custom_field: year, value: "1912")
    building.custom_field_values.create!(custom_field: former_use, value: "Former train station")
    building.custom_field_values.create!(custom_field: status, value: "State")
  end

  client.buildings.create!(address: "500 Colonial Way", state: "MA", zip: "02103").tap do |building|
    building.custom_field_values.create!(custom_field: year, value: "1845")
    building.custom_field_values.create!(custom_field: former_use, value: "")
    building.custom_field_values.create!(custom_field: status, value: "Local")
  end
end

# Client 4: Luxury Estates
Client.create!(name: "Prestige Property Management").tap do |client|
  bathrooms = client.custom_fields.create!(name: "Bathrooms", field_type: :number)
  pool = client.custom_fields.create!(name: "Pool Type", field_type: :enum_type, enum_options: [ "In-ground", "Above-ground", "None" ])
  view = client.custom_fields.create!(name: "View Description", field_type: :freeform)

  client.buildings.create!(address: "1 Ocean Dr", state: "FL", zip: "33139").tap do |building|
    building.custom_field_values.create!(custom_field: bathrooms, value: "4.5")
    building.custom_field_values.create!(custom_field: pool, value: "In-ground")
    building.custom_field_values.create!(custom_field: view, value: "Panoramic ocean views")
  end

  client.buildings.create!(address: "2500 Mountain Crest", state: "CO", zip: "80401").tap do |building|
    building.custom_field_values.create!(custom_field: bathrooms, value: "3")
    building.custom_field_values.create!(custom_field: pool, value: "None")
    building.custom_field_values.create!(custom_field: view, value: "Mountain and valley views")
  end
end

# Client 5: Industrial Warehouse
Client.create!(name: "Logistics Real Estate Partners").tap do |client|
  ceiling = client.custom_fields.create!(name: "Ceiling Height (ft)", field_type: :number)
  loading = client.custom_fields.create!(name: "Loading Docks", field_type: :number)
  floor = client.custom_fields.create!(name: "Floor Type", field_type: :enum_type, enum_options: [ "Concrete", "Epoxy-coated", "Polished" ])

  client.buildings.create!(address: "5000 Industrial Pkwy", state: "TX", zip: "75001").tap do |building|
    building.custom_field_values.create!(custom_field: ceiling, value: "32")
    building.custom_field_values.create!(custom_field: loading, value: "12")
    building.custom_field_values.create!(custom_field: floor, value: "Epoxy-coated")
  end

  client.buildings.create!(address: "8800 Warehouse Way", state: "TX", zip: "75002").tap do |building|
    building.custom_field_values.create!(custom_field: ceiling, value: "28")
    building.custom_field_values.create!(custom_field: loading, value: "8")
    building.custom_field_values.create!(custom_field: floor, value: "Concrete")
  end

  client.buildings.create!(address: "1200 Distribution Dr", state: "TX", zip: "75003").tap do |building|
    building.custom_field_values.create!(custom_field: ceiling, value: "40")
    building.custom_field_values.create!(custom_field: loading, value: "16")
    building.custom_field_values.create!(custom_field: floor, value: "Polished")
  end
end

puts "Seed data created successfully!"
puts "#{Client.count} clients"
puts "#{CustomField.count} custom fields"
puts "#{Building.count} buildings"
puts "#{CustomFieldValue.count} custom field values"
