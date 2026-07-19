# ⚡ QUICK BILLING ENGINE — Prompt for AI Coding Agent
## CyberCafe ERP Pro — Uncle's Fast Billing Module

---

## CONTEXT

This is a **Flutter Desktop (Windows)** application module.
The complete PRD already exists. This prompt focuses on building the
**core daily workflow** that the shop owner will use 50–100 times every day.

The owner (non-technical, older user) must be able to:
1. Set item prices **once** — never retype them again
2. Open a bill in **2 clicks**
3. Just select customer → tap items → enter quantity → DONE
4. Bill auto-calculates, auto-signs, auto-ready to print or WhatsApp

**Speed is everything. Minimum clicks. Maximum automation.**

---

## MODULE 1 — ITEM/SERVICE PRICE MASTER (Set Once, Use Forever)

### Screen: "My Services & Items" (Settings area)

Build a simple **price list screen** where owner sets prices ONE TIME.

#### Features:

```
Each item has:
├── Item Name          (e.g., "Color Print A4", "Aadhaar Update", "Photocopy")
├── Short Name         (e.g., "CLR A4", "ADHR", "XROX") ← for quick search
├── Category           (Print / Xerox / Cyber / Govt Service / Custom)
├── Unit               (Per Page / Per Hour / Per Set / Per Form / Flat)
├── Default Price (₹)  ← SET ONCE, AUTO-FILLS IN EVERY BILL
├── GST Rate (%)       (0% / 5% / 12% / 18% — dropdown)
├── HSN/SAC Code       (optional, auto-fill from category)
├── Active / Hidden    (hide seasonal services)
└── Sort Order         (drag to reorder — most used on top)
```

#### Pre-loaded Items for Cyber Café (ready to use, just edit price):

| # | Item Name | Unit | Default Price |
|---|---|---|---|
| 1 | Color Print A4 | Per Page | ₹10 |
| 2 | Black & White Print A4 | Per Page | ₹2 |
| 3 | Color Print A3 | Per Page | ₹20 |
| 4 | B&W Print A3 | Per Page | ₹5 |
| 5 | Xerox / Photocopy A4 | Per Page | ₹1 |
| 6 | Xerox Color A4 | Per Page | ₹8 |
| 7 | Lamination A4 | Per Piece | ₹15 |
| 8 | Lamination A3 | Per Piece | ₹25 |
| 9 | Spiral Binding | Per Book | ₹30 |
| 10 | Hard Binding | Per Book | ₹80 |
| 11 | Passport Photo (set of 4) | Per Set | ₹50 |
| 12 | Passport Photo (set of 6) | Per Set | ₹70 |
| 13 | ID Card Making | Per Card | ₹30 |
| 14 | Scanning (per page) | Per Page | ₹5 |
| 15 | Typing (per page) | Per Page | ₹15 |
| 16 | Computer Rental | Per Hour | ₹30 |
| 17 | Internet Browsing | Per Hour | ₹20 |
| 18 | Aadhaar New Enrollment | Flat | ₹50 |
| 19 | Aadhaar Update / Correction | Flat | ₹50 |
| 20 | Aadhaar Address Update | Flat | ₹50 |
| 21 | PAN Card Apply | Flat | ₹100 |
| 22 | PAN Card Correction | Flat | ₹100 |
| 23 | Voter ID Apply | Flat | ₹50 |
| 24 | Income Certificate | Flat | ₹100 |
| 25 | Caste Certificate | Flat | ₹100 |
| 26 | Domicile Certificate | Flat | ₹100 |
| 27 | Birth Certificate | Flat | ₹80 |
| 28 | Death Certificate | Flat | ₹80 |
| 29 | Train Ticket (IRCTC) | Flat | ₹30 |
| 30 | Air Ticket | Flat | ₹150 |
| 31 | Bus Ticket | Flat | ₹30 |
| 32 | Passport Application | Flat | ₹200 |
| 33 | Visa Application | Flat | ₹300 |
| 34 | Mobile Recharge | Per Txn | ₹10 |
| 35 | DTH Recharge | Per Txn | ₹10 |
| 36 | Electricity Bill | Per Txn | ₹20 |
| 37 | Gas Bill Payment | Per Txn | ₹20 |
| 38 | Water Bill Payment | Per Txn | ₹20 |
| 39 | GST Registration | Flat | ₹500 |
| 40 | Income Tax Return | Flat | ₹300 |
| 41 | Courier / Speed Post | Flat | ₹50 |
| 42 | Custom Service | Custom | — |

#### Price Update Flow (when price increases):
```
Owner opens "My Services" → clicks ✏️ on any item
→ changes "Default Price" field
→ clicks Save
→ ALL future bills use new price automatically
→ OLD bills remain unchanged (historical accuracy)
```

#### UI Requirements:
- Big font (owner is older, needs readable text)
- Each item as a card with large price display
- Tap price → inline edit → save with ✅
- "Edit All Prices" bulk mode (spreadsheet-style for quick mass update)
- Import prices from Excel (optional)

---

## MODULE 2 — CUSTOMER QUICK-ADD (30 Seconds Max)

### Screen: "Customers"

Keep it SIMPLE. Uncle's customers are regulars.

```
Mandatory Fields Only:
├── Customer Name     (text input)
├── Phone Number      (10-digit, auto-validate)
└── [Save] Button

Optional Fields (expand on demand):
├── Email
├── GST Number        (if business customer)
├── Address
└── Customer Type     (Regular / Occasional / VIP / Government)
```

#### Smart Features:
- **Auto-search on phone number** — type 10 digits → if customer exists, auto-select (no duplicate)
- **Quick Customer** — walk-in customers saved as "Walk-in Customer" (no details needed)
- **Recent Customers** — last 10 customers shown on quick-access bar in billing screen
- **Customer Balance shown** — ₹ outstanding shown next to name (red if overdue)
- **Favourites** — star ⭐ marks frequent customers (appear at top always)

---

## MODULE 3 — ⚡ QUICK BILL SCREEN (The Main Feature)

### This is uncle's daily screen. Design it like a POS (Point of Sale) system.

### Layout (Split Screen — Windows Desktop):

```
┌─────────────────────────────────────────────────────────────────────┐
│  ⚡ New Bill          [Bill No: INV-2026-0042]    [Date: 19/07/2026] │
├──────────────────────────────┬──────────────────────────────────────┤
│                              │                                      │
│   LEFT PANEL (60%)           │   RIGHT PANEL (40%)                  │
│   Item Selection             │   Bill Summary                       │
│                              │                                      │
│  👤 Customer                 │  ┌─────────────────────────────┐    │
│  [Search / Select ▼]         │  │ BILL ITEMS                  │    │
│  [+ Quick Add]               │  │ ─────────────────────────── │    │
│                              │  │ Color Print A4   ×5  ₹50   │    │
│  🔍 [Search items...]        │  │ Aadhaar Update   ×1  ₹50   │    │
│                              │  │ Passport Photo   ×1  ₹50   │    │
│  📂 Category Filter:         │  │                             │    │
│  [All] [Print] [Xerox]       │  │ ─────────────────────────── │    │
│  [Govt] [Cyber] [Custom]     │  │ Subtotal:        ₹150.00   │    │
│                              │  │ GST (18%):       ₹27.00    │    │
│  ┌──────────┐ ┌──────────┐  │  │ ─────────────────────────── │    │
│  │Color A4  │ │ B&W A4   │  │  │ TOTAL:           ₹177.00   │    │
│  │  ₹10/pg  │ │  ₹2/pg   │  │  └─────────────────────────┘    │    │
│  └──────────┘ └──────────┘  │                                      │
│  ┌──────────┐ ┌──────────┐  │  💵 Payment Received: [₹200___]      │
│  │  Xerox   │ │Aadhaar   │  │  💰 Balance/Change:   ₹23.00        │
│  │  ₹1/pg   │ │  ₹50     │  │                                      │
│  └──────────┘ └──────────┘  │  [💾 Save Draft]  [🖨️ Print & Save] │
│                              │  [📱 WhatsApp]    [📄 PDF Save]     │
└──────────────────────────────┴──────────────────────────────────────┘
```

### Item Selection Behavior:

```
Uncle taps any item card (e.g., "Color Print A4")
→ A small popup appears:

  ┌─────────────────────────┐
  │  Color Print A4         │
  │  Price: ₹10 per page    │
  │                         │
  │  Quantity: [___5___]    │
  │  (keyboard opens here)  │
  │                         │
  │  Total: ₹50             │
  │                         │
  │  [Cancel]  [✅ Add]     │
  └─────────────────────────┘

→ Tap ✅ Add → item instantly appears in Right Panel
→ Popup closes → ready to tap next item
```

### Item Card Design:
- Large readable font (min 14pt)
- Item name bold
- Price in GREEN color
- If item already in bill: card shows orange border + qty badge
- Tap already-added item → opens edit popup (change qty or remove)

### Bill Items Panel (Right Side):
- Each item row: Name | Qty | Price | Total | ✕
- Tap any row to edit qty
- Swipe right to delete (or ✕ button)
- Long press to add note to that item
- Reorder items by dragging

### Quantity Entry:
- Number pad opens automatically (big buttons for uncle)
- Default qty = 1 (just press ✅ Add to add 1 unit quickly)
- For printing services: qty = number of pages typed
- Support decimal qty (e.g., 0.5 hour = ₹15 for internet)

### Auto-Calculation (Instant, No Button Needed):
```
Every time item is added / qty changed:
→ Subtotal = sum of (qty × price) for all items
→ GST = calculated per item's GST rate
→ Grand Total = Subtotal + GST - Discount
→ Change = Payment Received - Grand Total
All calculations happen in real-time, under 50ms
```

### Discount (Quick):
- [+ Add Discount] button → choose flat ₹ or %
- Applied to whole bill
- Show original vs discounted price

### Payment Collection:
```
"Payment Received" field:
→ Uncle types amount received (e.g., ₹200)
→ "Change to Return: ₹23" auto-shows
→ If payment < total: "Balance Due: ₹27" (add to customer credit)
→ Payment mode: [Cash] [UPI] [Credit] (one tap selection)
```

---

## MODULE 4 — AUTO BILL GENERATION (Zero Manual Work)

### After clicking "Print & Save" — fully automatic:

```
Step 1: Bill saved to database (auto bill number assigned)
Step 2: Customer ledger updated automatically
Step 3: Stock reduced (if inventory items)
Step 4: GST ledger updated automatically
Step 5: Bill PDF generated (from saved template)
Step 6: Signature auto-stamped (from settings image)
Step 7: Bill sent to printer / WhatsApp / saved as PDF
Step 8: Bill stored in Windows folder:
        Documents\CyberCafeERP\Invoices\2026\July\INV-042.pdf

Total time from "Print & Save" click to paper out: < 3 seconds
```

### Auto Bill Features:
- **Auto Bill Number** — never repeated, never manual
- **Auto Date & Time** — from system clock
- **Auto GST Calculation** — no uncle needs to know GST
- **Auto Amount in Words** — "Rupees One Hundred Seventy Seven Only"
- **Auto Signature** — owner signature image from settings
- **Auto Stamp** — shop stamp image from settings
- **Auto Shop Details** — name, address, GST, phone from settings
- **Auto Customer Details** — from customer record
- **Auto Footer** — "Thank You for Visiting!" + shop phone + UPI QR

---

## MODULE 5 — BILL HISTORY (Per Customer)

### Screen: Customer → View Bills

```
Customer: Ramesh Kumar (📞 9876543210)
Outstanding: ₹0 | Total Purchases: ₹12,450

─────────────────────────────────────────────────
Date       Bill No    Items              Amount   Status
─────────────────────────────────────────────────
19 Jul 26  INV-042   Color Print×5+...  ₹177    ✅ Paid
18 Jul 26  INV-039   Aadhaar Update     ₹50     ✅ Paid
15 Jul 26  INV-031   PAN Card Apply     ₹100    ✅ Paid
─────────────────────────────────────────────────

[🖨️ Reprint]  [📱 Resend WhatsApp]  [📄 PDF]
```

- Tap any bill → open full bill view
- Reprint any old bill with one click
- Resend to WhatsApp anytime
- Filter: This Week / This Month / Custom Date

---

## MODULE 6 — DAILY SUMMARY (End of Day — 1 Screen)

### Screen: "Today's Report" (Ctrl+R)

Uncle opens this at end of day to see how business went.

```
📅 Today: Sunday, 19 July 2026
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💰 Total Sales:        ₹4,250
🧾 Total Bills:        23 bills
💵 Cash Collected:     ₹3,800
📱 UPI Collected:      ₹450
🔴 Pending/Credit:     ₹0

📊 TOP SERVICES TODAY:
  1. Color Print A4   → 145 pages  → ₹1,450
  2. Aadhaar Update   → 12 times   → ₹600
  3. Xerox A4         → 200 pages  → ₹200
  4. PAN Card Apply   → 5 times    → ₹500
  5. Train Ticket     → 3 times    → ₹90

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[🖨️ Print Day Report]  [📱 WhatsApp Report]
```

---

## MODULE 7 — BILL TEMPLATE (Auto Print Design)

### Default template for uncle — simple, clean, professional:

```
┌─────────────────────────────────────────┐
│          🏪 [SHOP NAME]                 │
│  [Address Line 1], [City] - [PIN]       │
│  📞 [Phone]  |  GST: [GSTIN]           │
│─────────────────────────────────────────│
│  BILL NO: INV-042     DATE: 19/07/2026  │
│  Customer: Ramesh Kumar (9876543210)    │
│─────────────────────────────────────────│
│  #  ITEM              QTY  PRICE  TOTAL │
│  1  Color Print A4     5   ₹10   ₹50   │
│  2  Aadhaar Update     1   ₹50   ₹50   │
│  3  Passport Photo     1   ₹50   ₹50   │
│─────────────────────────────────────────│
│                  Subtotal:    ₹150.00   │
│                  GST (18%):   ₹27.00   │
│              ━━━━━━━━━━━━━━━━━━━━━━━━━ │
│              TOTAL:           ₹177.00  │
│─────────────────────────────────────────│
│  Paid: ₹200    Change: ₹23             │
│─────────────────────────────────────────│
│  Amount: One Hundred Seventy Seven Only │
│                                         │
│  [Signature Image]     [Stamp Image]    │
│─────────────────────────────────────────│
│   Thank you! Visit Again 🙏             │
│   Pay via UPI: [UPI_ID]  [QR CODE]     │
└─────────────────────────────────────────┘
```

### Template Settings (Easy for Uncle):
- Uncle can change: font size, add/remove QR, show/hide GST breakup
- Two modes: A4 Print / Thermal Print (80mm) — auto-switch per printer
- Thermal mode: compact, no logo (saves paper, faster print)

---

## TECHNICAL IMPLEMENTATION NOTES

### Tech Stack (same as main PRD):
- Flutter Desktop Windows
- SQLite (local, offline-first)
- MongoDB (cloud sync — optional)
- Riverpod (state management)
- pdf + printing packages (Flutter)
- win32 (Windows printer access)

### Performance Requirements:
```
- Item search response:      < 100ms
- Bill total recalculation:  < 50ms (real-time as uncle types)
- PDF generation:            < 1 second
- Print to paper:            < 3 seconds total
- App open to bill ready:    < 5 seconds
```

### Database Tables for This Module:
```sql
items_master (
  id, name, short_name, category, unit,
  default_price, gst_rate, hsn_code,
  is_active, sort_order, created_at, updated_at
)

customers (
  id, name, phone, email, gstin, address,
  customer_type, outstanding_balance,
  is_favourite, created_at
)

bills (
  id, bill_number, bill_date, customer_id,
  subtotal, gst_amount, discount, grand_total,
  payment_received, payment_mode, change_amount,
  status, notes, created_at
)

bill_items (
  id, bill_id, item_id, item_name,
  quantity, unit_price, gst_rate,
  gst_amount, total_amount
)
```

### Build Order for Developer:
```
Week 1: Items Master screen + price management
Week 2: Customer quick-add + recent customer bar
Week 3: Quick Bill screen layout (split panel UI)
Week 4: Item tap → qty popup → add to bill logic
Week 5: Auto-calculation engine + payment collection
Week 6: PDF generation + thermal/A4 print
Week 7: Bill history + daily summary screen
Week 8: Testing + polish + uncle training
```

---

## SUCCESS CRITERIA (Uncle Can Do This):

✅ Uncle opens app → clicks "New Bill" → screen ready in 2 seconds
✅ Uncle selects Ramesh from recent customers in 1 tap
✅ Uncle taps "Color Print A4" → types 15 → taps Add — DONE in 5 seconds
✅ Uncle taps 4 more services — bill complete in under 1 minute
✅ Uncle types ₹500 received → sees "Change: ₹173" instantly
✅ Uncle clicks "Print" → paper comes out in 3 seconds
✅ Uncle clicks "WhatsApp" → Ramesh gets bill on phone in 10 seconds
✅ Uncle checks "Today's Report" at 8PM → sees ₹6,200 total in 1 click
✅ Uncle wants to increase color print price → changes ₹10 to ₹12 in 30 seconds
✅ Next bill — color print auto-shows ₹12 — no retraining needed

---

*"Ek baar setup karo, zindagi bhar use karo."*
*Quick Billing Engine — Built for Uncle, Powered by Flutter.*
