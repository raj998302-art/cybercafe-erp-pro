# CyberCafe ERP Pro

> A complete **GST Billing + Tally-style Accounting + CorelDRAW-style Invoice Designer** application for Indian cyber cafes, print shops, CSC centers, and digital service providers.

Built with **Flutter** (Windows desktop + Android) and a **Node.js + Express + MongoDB** backend.

Inspired by **Tally Prime + CorelDRAW + Vyapar + Busy Accounting**.

---

## What's inside

### Flutter App (`/`)
- **Dashboard** — today's sales, bills count, quick actions
- **GST Billing** — create invoices with auto GST calc (CGST/SGST/IGST), round-off, payment status
- **Customers** — full CRM with GSTIN, opening balance, tags
- **Items / Services** — price master with 42 pre-loaded cyber cafe items
- **Accounting** — Tally-style vouchers & ledgers, day book, trial balance
- **GST Returns** — GSTR-1 & GSTR-3B view per period
- **Reports** — sales summary, GST summary, top customers/items, profit & loss
- **Settings** — company profile, backup to Windows file system, MongoDB cloud sync
- **Offline-first** — SQLite local DB + MongoDB Atlas cloud sync
- **Windows native** — system tray, file backup, DPI-aware window

### Backend (`/backend`)
- Express + Mongoose + JWT auth
- Full REST API for all modules
- GST calculation engine (intra/inter-state)
- GSTR-1 / GSTR-3B generators
- Backup export/import (full DB as JSON)
- Cloud sync endpoints

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter Desktop (Windows) + Flutter Android |
| State | Provider |
| Routing | GoRouter |
| Local DB | SQLite (sqflite_common_ffi) |
| Backend | Node.js + Express 4 |
| Database | MongoDB Atlas (Mongoose 8) |
| Auth | JWT + bcryptjs |
| Security | Helmet, CORS, Rate limiting |
| CI/CD | GitHub Actions |

---

## Project Structure

```
cybercafe-erp/
├── lib/                          # Flutter app source
│   ├── app/                      # App entry, router, theme
│   ├── core/
│   │   ├── config/               # AppConfig
│   │   ├── database/             # SQLite init + DbHelper
│   │   ├── services/             # ApiService, GstService
│   │   └── backup/               # Windows file backup
│   ├── features/
│   │   ├── dashboard/            # Home screen
│   │   ├── billing/              # Invoice list + create
│   │   ├── customers/            # Customer CRM
│   │   ├── inventory/            # Items & prices
│   │   ├── accounting/           # Vouchers & ledgers
│   │   ├── gst/                  # GST returns
│   │   ├── reports/              # Analytics
│   │   └── settings/             # Settings & backup
│   └── shared/
│       ├── models/               # Customer, Item, Bill
│       ├── providers/            # Provider state
│       ├── theme/                # Material 3 theme
│       └── widgets/              # Shell scaffold
├── android/                      # Android build config
├── windows/                      # Windows runner (C++)
├── backend/                      # Node.js + Express API
│   └── src/
│       ├── config/               # DB + constants
│       ├── models/               # Mongoose schemas
│       ├── routes/               # REST endpoints
│       ├── services/             # GST + bill + seed logic
│       ├── middleware/           # Auth, error, validate
│       └── utils/                # Logger, response, INR format
├── .github/workflows/            # CI: build APK + Windows exe
├── docs/
│   ├── PRD.md                    # Full product requirements
│   └── QuickBilling_Uncle_Prompt.md  # Uncle's quick-start prompt
└── pubspec.yaml
```

---

## Getting Started

### 1. Run the backend

```bash
cd backend
npm install
npm run dev
# → http://localhost:5000/api/health
```

Seed default data:

```bash
curl -X POST http://localhost:5000/api/sync/seed
# Creates admin (admin/admin123) + 42 cyber cafe items
```

### 2. Run the Flutter app

```bash
flutter pub get
flutter run -d windows     # Windows desktop
flutter run -d chrome      # Web preview
```

### 3. Build APK (Android)

```bash
flutter build apk --release
# → build/app/outputs/flutter-apk/app-release.apk
```

### 4. Build Windows .exe

```bash
flutter build windows --release
# → build/windows/x64/runner/Release/CyberCafeERP.exe
```

---

## GitHub Actions (CI/CD)

Two workflows are included in `.github/workflows/`:

### `build-android-apk.yml`
- Triggers on push to `main`, version tags (`v*`), and manual dispatch
- Builds a release APK
- Uploads as artifact + creates a GitHub Release (on tag/manual)

### `build-windows-exe.yml`
- Triggers on push to `main`, tags (`win-v*`), and manual dispatch
- Builds the Windows .exe
- Zips the release folder and uploads as artifact + release

### Download APKs from Releases

After a tagged push (e.g. `git tag v1.0.0 && git push origin v1.0.0`),
the APK appears under **Releases** on the GitHub repo page.

---

## Default Cyber Cafe Items (42 pre-loaded)

Color/B&W prints, Xerox, lamination, binding, passport photos, ID cards,
scanning, typing, computer rental, internet browsing, Aadhaar/PAN/Voter ID,
income/caste/domicile/birth/death certificates, train/air/bus tickets,
passport/visa, mobile/DTH/electricity/gas/water bill payments,
GST registration, ITR, courier — and a "Custom Service" slot.

See `lib/shared/models/item.dart` and `backend/src/config/constants.js`.

---

## Documentation

- **Full PRD:** [`docs/PRD.md`](docs/PRD.md) — 14 phases, database schema, folder structure
- **Uncle's Quick-Start Prompt:** [`docs/QuickBilling_Uncle_Prompt.md`](docs/QuickBilling_Uncle_Prompt.md)
- **Backend API:** [`backend/README.md`](backend/README.md)

---

## License

Built for a specific Indian cyber cafe owner. MIT-style — free to use and modify.
