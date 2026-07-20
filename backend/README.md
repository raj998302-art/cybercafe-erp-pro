# CyberCafe ERP Pro — Backend

Node.js + Express + MongoDB backend for the CyberCafe ERP Pro Flutter app.

## Quick Start

```bash
cd backend
npm install
cp .env.example .env   # then edit .env with your MongoDB URI
npm run dev            # starts on http://localhost:5000
```

## Environment Variables

| Variable | Description |
|---|---|
| `MONGODB_URI` | MongoDB Atlas connection string |
| `PORT` | Server port (default 5000) |
| `JWT_SECRET` | Secret for signing JWT tokens |
| `JWT_EXPIRES_IN` | Token expiry (default 30d) |
| `CLIENT_URL` | CORS origin (`*` for all) |

## Default Admin

On first run, call `POST /api/auth/seed-admin` or `POST /api/sync/seed` to create:

- **Username:** `admin`
- **Password:** `admin123`

## API Endpoints

| Method | Route | Description |
|---|---|---|
| `GET` | `/api/health` | Health check |
| `POST` | `/api/auth/login` | Login → returns JWT |
| `POST` | `/api/auth/register` | Register new user |
| `GET` | `/api/auth/me` | Current user (auth) |
| `POST` | `/api/auth/seed-admin` | Seed default admin |
| `GET/PUT` | `/api/company` | Get / upsert company profile |
| `GET/POST/PUT/DELETE` | `/api/customer` | Customers CRUD |
| `GET/POST/PUT/DELETE` | `/api/supplier` | Suppliers CRUD |
| `GET/POST/PUT/DELETE` | `/api/item` | Items & services CRUD |
| `GET` | `/api/item/seed` | Seed 42 default cyber cafe items |
| `GET/POST/PUT/DELETE` | `/api/bill` | Bills (invoices) CRUD |
| `GET` | `/api/bill/today/count` | Today's bill count + sales |
| `GET` | `/api/bill/month/summary` | Current month summary |
| `GET/POST` | `/api/accounting/ledgers` | Ledgers (chart of accounts) |
| `GET/POST` | `/api/accounting/vouchers` | Vouchers (double-entry) |
| `GET` | `/api/accounting/daybook` | Day book |
| `GET` | `/api/accounting/trial-balance` | Trial balance |
| `GET/POST/PUT/DELETE` | `/api/expense` | Expenses CRUD |
| `GET` | `/api/report/sales-summary` | Daily sales summary |
| `GET` | `/api/report/gst-summary` | GST collected summary |
| `GET` | `/api/report/top-customers` | Top customers |
| `GET` | `/api/report/top-items` | Top selling items |
| `GET` | `/api/report/profit-loss` | Profit & loss statement |
| `GET` | `/api/gst/gstr1?from=&to=` | GSTR-1 report |
| `GET` | `/api/gst/gstr3b?month=YYYY-MM` | GSTR-3B report |
| `POST` | `/api/backup/export` | Export entire DB as JSON |
| `POST` | `/api/backup/import` | Import JSON into DB |
| `GET` | `/api/sync/all` | Full sync dump |
| `POST` | `/api/sync/push` | Push upserts |
| `POST` | `/api/sync/seed` | Seed admin + default items |

## Tech Stack

- Express 4 + Helmet + CORS + Rate limiting
- Mongoose 8 (MongoDB ODM)
- JWT authentication + bcryptjs password hashing
- Morgan HTTP logging
- ES Modules (`"type": "module"`)
