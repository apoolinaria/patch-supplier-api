require "rails_helper"
require "rswag/specs"

RSpec.configure do |config|
  config.openapi_root = Rails.root.join("swagger").to_s

  config.openapi_specs = {
    "v1/swagger.yaml" => {
      openapi: "3.0.1",
      info: {
        title: "Patch Supplier API",
        version: "v1",
        description: "REST API for carbon offset suppliers to manage inventory, " \
                      "upload fulfillment proofs, and view payouts."
      },
      servers: [
        { url: "http://localhost:3000", description: "Local development" }
      ],
      components: {
        securitySchemes: {
          bearerAuth: {
            type: :http,
            scheme: :bearer,
            description: "API key issued per project (format: key_test_<hex>)"
          }
        },
        schemas: {
          Offset: {
            type: :object,
            properties: {
              id:               { type: :integer, example: 1 },
              project_id:       { type: :integer, example: 1 },
              name:             { type: :string,  example: "Gold Standard REDD+ Congo Basin" },
              sku:              { type: :string,  example: "gold-standard-redd-congo-basin-abc123" },
              mass_g:           { type: :integer, example: 1_000_000, description: "Total mass in grams" },
              price_cents_usd:  { type: :integer, example: 50_000, description: "Price in USD cents" },
              retired:          { type: :boolean, example: false },
              created_at:       { type: :string, format: :"date-time" },
              updated_at:       { type: :string, format: :"date-time" }
            },
            required: %w[id project_id name sku mass_g price_cents_usd retired]
          },
          OffsetInput: {
            type: :object,
            properties: {
              offset: {
                type: :object,
                properties: {
                  name:            { type: :string,  example: "Gold Standard REDD+ Congo Basin" },
                  mass_g:          { type: :integer, example: 1_000_000 },
                  price_cents_usd: { type: :integer, example: 50_000 }
                },
                required: %w[name mass_g price_cents_usd]
              }
            }
          },
          FulfillmentProof: {
            type: :object,
            properties: {
              id:            { type: :integer, example: 1 },
              offset_id:     { type: :integer, example: 3 },
              mass_g:        { type: :integer, example: 500_000 },
              serial_number: { type: :string,  example: "VCS-2024-00123" },
              created_at:    { type: :string, format: :"date-time" },
              updated_at:    { type: :string, format: :"date-time" }
            },
            required: %w[id offset_id mass_g serial_number]
          },
          FulfillmentProofInput: {
            type: :object,
            properties: {
              fulfillment_proof: {
                type: :object,
                properties: {
                  mass_g:        { type: :integer, example: 500_000 },
                  serial_number: { type: :string,  example: "VCS-2024-00123" }
                },
                required: %w[mass_g serial_number]
              }
            }
          },
          PayoutList: {
            type: :object,
            properties: {
              project_id: { type: :integer, example: 1 },
              payouts: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id:              { type: :integer, example: 1 },
                    offset_id:       { type: :integer, example: 3 },
                    offset_name:     { type: :string,  example: "Gold Standard REDD+ Congo Basin" },
                    amount_cents_usd: { type: :integer, example: 50_000 },
                    status:          { type: :string,  enum: %w[pending_approval completed], example: "pending_approval" },
                    created_at:      { type: :string,  format: :"date-time" }
                  }
                }
              }
            }
          },
          ErrorResponse: {
            type: :object,
            properties: {
              errors: {
                type: :array,
                items: { type: :string },
                example: [ "Name can't be blank", "Mass g must be greater than 0" ]
              }
            }
          },
          UnauthorizedResponse: {
            type: :object,
            properties: {
              error: { type: :string, example: "Unauthorized" }
            }
          },
          NotFoundResponse: {
            type: :object,
            properties: {
              error: { type: :string, example: "Offset not found" }
            }
          }
        }
      },
      security: [ { bearerAuth: [] } ]
    }
  }

  config.openapi_format = :yaml
end
