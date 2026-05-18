FulfillmentProof.delete_all
Payout.delete_all
Order.delete_all
Offset.delete_all
Project.delete_all

biomass  = Project.create!(name: "biomass",  api_key: "key_test_#{SecureRandom.hex(16)}")
forestry = Project.create!(name: "forestry", api_key: "key_test_#{SecureRandom.hex(16)}")
dac      = Project.create!(name: "dac",      api_key: "key_test_#{SecureRandom.hex(16)}")

biomass_offset_1 = Offset.create!(project: biomass,  name: "Biomass Removal", mass_g: 100_000_000, price_cents_usd: 5_000_000)
biomass_offset_2 = Offset.create!(project: biomass,  name: "Reforestation",   mass_g:  50_000_000, price_cents_usd: 2_500_000)
forestry_offset  = Offset.create!(project: forestry, name: "Carbon Removal",  mass_g: 200_000_000, price_cents_usd: 2_000_000)
dac_offset_1     = Offset.create!(project: dac,      name: "DAC Phase 1",     mass_g:  10_000_000, price_cents_usd:   300_000)
dac_offset_2     = Offset.create!(project: dac,      name: "DAC Phase 2",     mass_g:  10_000_000, price_cents_usd:   300_000)

[
  { offset: dac_offset_1,     mass_g:  2_000_000 },
  { offset: dac_offset_1,     mass_g:  4_000_000 },
  { offset: dac_offset_1,     mass_g:  4_000_000 },
  { offset: biomass_offset_1, mass_g:  1_000_000 },
  { offset: biomass_offset_1, mass_g: 10_000_000 },
  { offset: biomass_offset_1, mass_g: 20_000_000 },
  { offset: forestry_offset,  mass_g: 100_000_000 },
  { offset: biomass_offset_2, mass_g: 25_000_000 },
  { offset: biomass_offset_2, mass_g: 25_000_000 },
  { offset: dac_offset_2,     mass_g:  5_000_000 },
  { offset: dac_offset_2,     mass_g:  5_000_000 }
].each do |attrs|
  Order.create!(attrs)
end

puts "\nAPI keys (use as Bearer token in Authorization header):"
Project.order(:name).each do |project|
  puts "  [id=#{project.id}] #{project.name.ljust(10)} → #{project.api_key}"
end
