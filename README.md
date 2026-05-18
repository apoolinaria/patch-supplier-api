# Patch Supplier API

A Rails 8.1 API for carbon offset suppliers to manage inventory, upload fulfillment proofs, and track payouts.

---

## Requirements

- Ruby 3.4.4
- PostgreSQL 14+
- Bundler 2+

---

## Setup

```bash
bundle install
rails db:create db:migrate db:seed
rails server
```

`db:seed` loads the starter dataset (projects, offsets, orders) and prints each project's (supplier/company for this excersise) API key to stdout:

```
=== API Keys ===
Pachama     →  key_test_abc123...
South Pole  →  key_test_def456...
...
```

Use these keys in the `Authorization` header for all requests.

---

## Authentication

Authentication is intentionally simplified for this exercise — a single `api_key` column lives directly on the `Project` model. If auth were a full requirement, I would use OAuth via Doorkeeper with a dedicated tokens table, so a project can hold multiple tokens (e.g. separate sandbox and production keys) and tokens can be rotated or revoked independently.

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

### Endpoints

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

If this proof brings the total fulfilled mass up to the offset's full `mass_g` — and all of that mass has also been ordered — the offset is automatically **retired** and a payout is created with status `pending_approval`.

### List payouts

Returns all payouts for the project, both `pending_approval` and `completed`, grouped by project ID.

```bash
curl http://localhost:3000/api/v1/projects/1/payouts \
  -H "Authorization: Bearer YOUR_KEY"
```

---

## Running Tests

```bash
bundle exec rspec
```
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
