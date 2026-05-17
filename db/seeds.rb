biomass  = Project.find_or_create_by!(name: "biomass", api_key: "key_test_#{SecureRandom.hex(16)}")
forestry = Project.find_or_create_by!(name: "forestry", api_key: "key_test_#{SecureRandom.hex(16)}")
dac      = Project.find_or_create_by!(name: "dac", api_key: "key_test_#{SecureRandom.hex(16)}")

biomass_offset_1 = Offset.find_or_create_by!(project: biomass,  name: "Biomass Removal") { |o| o.mass_g = 100_000_000; o.price_cents_usd = 5_000_000 }
biomass_offset_2 = Offset.find_or_create_by!(project: biomass,  name: "Reforestation") { |o| o.mass_g =  50_000_000; o.price_cents_usd = 2_500_000 }
forestry_offset  = Offset.find_or_create_by!(project: forestry, name: "Carbon Removal")  { |o| o.mass_g = 200_000_000; o.price_cents_usd = 2_000_000 }
dac_offset_1     = Offset.find_or_create_by!(project: dac,      name: "DAC")          { |o| o.mass_g =  10_000_000; o.price_cents_usd =   300_000 }
dac_offset_2     = Offset.find_or_create_by!(project: dac,      name: "DAC")           { |o| o.mass_g =  10_000_000; o.price_cents_usd =   300_000 }

[
  { offset: dac_offset_1,    mass_g:  2_000_000 },
  { offset: dac_offset_1,    mass_g:  4_000_000 },
  { offset: dac_offset_1,    mass_g:  4_000_000 },
  { offset: biomass_offset_1, mass_g:  1_000_000 },
  { offset: biomass_offset_1, mass_g: 10_000_000 },
  { offset: biomass_offset_1, mass_g: 20_000_000 },
  { offset: forestry_offset,  mass_g: 100_000_000 },
  { offset: biomass_offset_2, mass_g: 25_000_000 },
  { offset: biomass_offset_2, mass_g: 25_000_000 },
  { offset: dac_offset_2,    mass_g:  5_000_000 }
].each do |attrs|
  Order.find_or_create_by!(attrs)
end

puts "\nAPI keys (use as Bearer token in Authorization header):"
Project.order(:name).each do |project|
  puts "  #{project.name.ljust(10)} → #{project.api_key}"
end
