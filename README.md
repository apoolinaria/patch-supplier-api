# Patch Supplier API

A Rails 8.1 API for carbon offset suppliers to manage inventory, upload fulfillment proofs, and track payouts.

---

## Requirements

- Ruby 3.2.2
- PostgreSQL 14+
- Bundler 2+

---

## Setup

```bash
bundle install
rails db:create db:migrate db:seed
rails server
```

`db:seed` loads the starter dataset (projects, offsets, orders) and prints each project's API key to stdout:

```
=== API Keys ===
Pachama     →  key_test_abc123...
South Pole  →  key_test_def456...
...
```

Use these keys in the `Authorization` header for all requests.

---

## Authentication

Every endpoint requires a Bearer token matching the `api_key` on the project record.

```
Authorization: Bearer key_test_<hex>
```

Requests with a missing or invalid key receive `401 Unauthorized`.

---

## API Documentation (Swagger UI)

Interactive docs are available at:

```
http://localhost:3000/api-docs
```

The Swagger UI lets you browse all endpoints, inspect request/response schemas, and execute requests directly in the browser using the **Authorize** button (paste your Bearer token there).

### Regenerating the spec

The `swagger/v1/swagger.yaml` file is generated from the integration specs in `spec/integration/`. To regenerate it after any API changes:

```bash
bundle exec rake rswag:specs:swaggerize
```

---

## Endpoints

All routes are namespaced under `/api/v1`.

| Method | Path | Description |
|--------|------|-------------|
| `GET`  | `/projects/:project_id/offsets` | List all offsets for the authenticated project |
| `POST` | `/projects/:project_id/offsets` | Create a new offset |
| `POST` | `/offsets/:offset_id/fulfillment_proofs` | Upload a fulfillment proof; triggers retirement + payout as a side effect |
| `GET`  | `/projects/:project_id/payouts` | List all payouts for the authenticated project |

---

## Sample curl Requests

Replace `YOUR_KEY` with the key printed during `db:seed`, and adjust IDs as needed.

### List offsets

```bash
curl http://localhost:3000/api/v1/projects/1/offsets \
  -H "Authorization: Bearer YOUR_KEY"
```

### Create an offset

```bash
curl -X POST http://localhost:3000/api/v1/projects/1/offsets \
  -H "Authorization: Bearer YOUR_KEY" \
  -H "Content-Type: application/json" \
  -d '{"offset": {"name": "VCS REDD+ Brazil", "mass_g": 2000000, "price_cents_usd": 80000}}'
```

### Upload a fulfillment proof

```bash
curl -X POST http://localhost:3000/api/v1/offsets/1/fulfillment_proofs \
  -H "Authorization: Bearer YOUR_KEY" \
  -H "Content-Type: application/json" \
  -d '{"fulfillment_proof": {"mass_g": 1000000, "serial_number": "VCS-2024-00123"}}'
```

If this proof causes the offset's total fulfilled mass to match both its total ordered mass and its declared `mass_g`, the offset is automatically **retired** and a payout record is created with status `pending_approval`.

### List payouts

```bash
curl http://localhost:3000/api/v1/projects/1/payouts \
  -H "Authorization: Bearer YOUR_KEY"
```

---

## Running Tests

```bash
bundle exec rspec
```

Specs live in:

- `spec/requests/api/v1/` — controller/request specs (auth, validations, happy paths)
- `spec/services/` — unit specs for `RetirementService` and `PayoutService`
- `spec/integration/api/v1/` — rswag swagger specs (also generate the OpenAPI YAML)

---

## Data Model

```
Project
  has_many :offsets
  has_many :payouts

Offset
  belongs_to :project
  has_many   :orders
  has_many   :fulfillment_proofs
  has_one    :payout

Order
  belongs_to :offset

FulfillmentProof
  belongs_to :offset

Payout
  belongs_to :project
  belongs_to :offset
```

---

## Key Design Decisions

### Payout creation on proof upload or on order creation (not on GET /payouts)

The spec implies payouts could be calculated lazily on `GET /payouts`. I chose to create them eagerly as a side effect of offset retirement, triggered inside `FulfillmentProofsController#create`. This means:

- Suppliers see a `pending_approval` payout immediately after the offset is retired.
- The `GET /payouts` endpoint is a simple read — no hidden writes on a GET.
- The finance team has an explicit `pending_approval → completed` approval step before anything is finalized.


### Retirement condition

An offset is retired when **both** conditions hold:

1. `total ordered mass >= offset.mass_g` — all mass has been sold.
2. `total fulfilled mass >= offset.mass_g` — a proof of fulfillment exists for all of that mass.

`RetirementService` is called after every proof upload. `PayoutService` runs only if the offset transitions to retired on that call.

**Assumption: `>=` not `==` for the retirement check.** Logically, total ordered mass should never exceed `offset.mass_g` — a supplier declares 100 units and customers can't order 101. `FulfillmentProof` enforces this cap with a model validation (`mass_g_within_remaining_capacity`). `Order` does not have an equivalent guard yet, so `>=` is used as a defensive default. A future improvement would be to verify if a strict comparison is needed and add a capacity validation on `Order` as well, at which point `>=` and `==` would be equivalent in practice.

### Payout amount

Because retirement guarantees that ordered mass == fulfilled mass == `offset.mass_g`, the payout amount is simply `offset.price_cents_usd`. I imagine that in real life the payouts are more complex, this is the assumption I made from my understanding of specs and clarifying question.

### Potential improvement: per-order partial payouts

Rachel mentioned that suppliers operate on very small margins, so waiting for an entire offset to be fully retired before receiving any payment could be a real cash-flow problem. A future improvement could be to trigger a payout for each individual order as soon as its corresponding fulfillment proof is uploaded, rather than waiting for the whole offset to be retired.

This would change the data model from `Offset has_one :payout` to `Offset has_many :payouts`, with each payout scoped to a specific order (`Payout belongs_to :order`). `PayoutService` would then calculate the payout amount as `order.mass_g / offset.mass_g * offset.price_cents_usd` for that slice of the offset.

### Atomicity

`FulfillmentProofsController#create` wraps proof creation, retirement check, and payout creation in a single `ApplicationRecord.transaction`. If any step fails, nothing is persisted.

### No background jobs

Retirement and payout creation happen synchronously in the request cycle. For a production system these would be good candidates for async jobs (e.g. Sidekiq) to avoid blocking the HTTP response.

### `mass_g` as integer (not bigint)

The maximum order size is 200,000,000 g (200 tonnes). This fits comfortably in a 32-bit `integer` (max ~2.1 billion), so `bigint` is unnecessary.

### Order cardinality: one-to-many, not one-to-one

The spec contains "each order is tied to one and only one `project_id`", which I initially read as implying a one-to-one relationship between orders and offsets. However, the seed data has multiple orders per offset, which makes the one-to-many relationship (`Offset has_many :orders`) the clear intent. The seed data is the source of truth here, so `Offset has_many :orders` is what's implemented.

The `1..200_000_000` g range from the spec is enforced on `Order#mass_g` only, as written. No upper bound is placed on `Offset#mass_g` since multiple orders can accumulate under a single offset.

### `serial_number` unique index on `fulfillment_proofs`

Serial numbers must be globally unique per certificate standard — a registry number cannot appear twice across different offsets. The unique index enforces this at the database level regardless of application-layer checks.
