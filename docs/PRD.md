# CyberCafe ERP Pro — MEGA PRD v2.0
## Complete GST Billing + Tally Accounting + CorelDRAW Invoice Designer

**Project Codename:** CyberCafe ERP Pro  
**Version:** 2.0 — Complete Edition  
**Target:** Windows Desktop (.exe) via Flutter Desktop SDK  
**Backend:** Node.js + Express + MongoDB Atlas  
**Inspired by:** Tally Prime + CorelDRAW + Vyapar + Busy Accounting  
**Built for:** Cyber Cafes, CSC Centers, Print Shops, Xerox Shops, Aadhaar Centers, Digital Service Centers, Computer Repair Shops, Stationery Shops

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Technology Stack](#2-technology-stack)
3. [Phase-wise Development Plan](#3-phase-wise-development-plan)
4. [Phase 1 — Foundation & Setup](#4-phase-1--foundation--setup)
5. [Phase 2 — GST Billing System (Full)](#5-phase-2--gst-billing-system-full)
6. [Phase 3 — Tally-Style Accounting Engine](#6-phase-3--tally-style-accounting-engine)
7. [Phase 4 — CorelDRAW-Style Invoice Designer](#7-phase-4--coreldraw-style-invoice-designer)
8. [Phase 5 — Inventory & Supplier Management](#8-phase-5--inventory--supplier-management)
9. [Phase 6 — Customer & CRM Module](#9-phase-6--customer--crm-module)
10. [Phase 7 — GST Compliance & Returns](#10-phase-7--gst-compliance--returns)
11. [Phase 8 — Reports & Analytics Engine](#11-phase-8--reports--analytics-engine)
12. [Phase 9 — Payroll & HR Module](#12-phase-9--payroll--hr-module)
13. [Phase 10 — Windows Integration & File System](#13-phase-10--windows-integration--file-system)
14. [Phase 11 — Multi-Company & Multi-Branch](#14-phase-11--multi-company--multi-branch)
15. [Phase 12 — Security, Backup & Sync](#15-phase-12--security-backup--sync)
16. [Phase 13 — Printing System](#16-phase-13--printing-system)
17. [Phase 14 — Advanced & Extra Features](#17-phase-14--advanced--extra-features)
18. [Database Schema Overview](#18-database-schema-overview)
19. [Folder Structure](#19-folder-structure)
20. [Final Deliverables](#20-final-deliverables)

---

## 1. Project Overview

### Goal

Build a **production-ready, offline-first Windows Desktop ERP application** for small Indian business owners — specifically cyber café and digital service center operators — that combines:

| Source Software | Features Borrowed |
|---|---|
| **Tally Prime** | Full double-entry accounting, all voucher types, GST returns, TDS/TCS, payroll, multi-company, cost centers, budgets, bank reconciliation, statutory reports |
| **CorelDRAW** | Drag-and-drop invoice designer, custom templates, font/color picker, image placement, watermark, digital signature, template library |
| **Vyapar** | Simple billing UI, WhatsApp sharing, mobile-style dashboard |
| **Busy Accounting** | Inventory management, barcode, batch/expiry tracking |
| **Microsoft Office** | Excel/Word export, print-ready layouts |

### Target Users

- Cyber Café owners with minimal accounting knowledge
- CSC (Common Service Center) operators
- Print & Xerox shop owners
- Computer repair shop owners
- Stationery shop owners
- Aadhaar/PAN service center operators
- Digital service providers

### Core Principles

1. **Offline First** — Works 100% without internet
2. **Auto-Save Everything** — No data loss ever
3. **One-Click GST** — GST calculation automatic
4. **Like Tally but Simple** — Full accounting without complexity
5. **Like CorelDRAW but Easy** — Beautiful invoices without design skill
6. **Windows Native** — Feels like a real Windows software

---

## 2. Technology Stack

### Frontend

```
Flutter Desktop SDK (Windows)
├── Material 3 UI
├── Fluent UI for Windows (microsoft/fluentui)
├── Riverpod (State Management)
├── Go Router (Navigation)
├── fl_chart (Charts & Graphs)
├── data_table_2 (Data Tables)
├── pdf (PDF generation)
├── printing (Print support)
├── win32 (Windows API integration)
├── file_picker (Native file dialogs)
├── path_provider (Windows paths)
├── syncfusion_flutter_charts (Advanced charts)
├── flutter_typeahead (Search autocomplete)
├── intl (Indian number formatting ₹)
├── qr_flutter (QR code generation)
├── barcode_widget (Barcode generation)
└── signature (Digital signature pad)
```

### Backend

```
Node.js + Express.js
├── Mongoose (MongoDB ODM)
├── JWT Authentication
├── bcrypt (Password hashing)
├── node-cron (Scheduled backups)
├── archiver (ZIP compression)
├── multer (File uploads)
├── nodemailer (Email)
├── PDFKit (Server-side PDF)
└── xlsx (Excel export)
```

### Database

```
MongoDB Atlas (Cloud)
├── Local SQLite (Offline cache via drift)
├── Hive (Fast local key-value)
└── Encrypted Storage (flutter_secure_storage)
```

### Printing

```
Windows Printer Stack
├── Thermal Printer (ESC/POS commands)
├── A4 / A5 / Legal Printers
├── Label Printers (Zebra, Dymo)
├── PDF Export (save as PDF printer)
└── Network Printers
```

---

## 3. Phase-wise Development Plan

| Phase | Module | Duration | Priority |
|---|---|---|---|
| Phase 1 | Foundation, Auth, Dashboard, Settings | 3 Weeks | 🔴 Critical |
| Phase 2 | GST Billing — Full Invoice System | 4 Weeks | 🔴 Critical |
| Phase 3 | Tally-Style Double Entry Accounting | 5 Weeks | 🔴 Critical |
| Phase 4 | CorelDRAW-Style Invoice Designer | 3 Weeks | 🟠 High |
| Phase 5 | Inventory, Stock, Supplier | 3 Weeks | 🟠 High |
| Phase 6 | Customer CRM, Ledger, Credit | 2 Weeks | 🟠 High |
| Phase 7 | GST Returns — GSTR-1, 3B, 9 | 3 Weeks | 🟠 High |
| Phase 8 | Reports Engine — All 50+ Reports | 3 Weeks | 🟡 Medium |
| Phase 9 | Payroll, HR, Attendance | 2 Weeks | 🟡 Medium |
| Phase 10 | Windows Integration, File Manager | 2 Weeks | 🟡 Medium |
| Phase 11 | Multi-Company, Multi-Branch | 2 Weeks | 🟡 Medium |
| Phase 12 | Security, Backup, Sync | 2 Weeks | 🟠 High |
| Phase 13 | Printing System — All Printer Types | 2 Weeks | 🟠 High |
| Phase 14 | Extra Features, Calculator, Notes | 2 Weeks | 🟢 Low |
| **Total** | | **~38 Weeks (~9-10 Months)** | |

> **MVP (Minimum Viable Product)** = Phase 1 + Phase 2 + Phase 3 + Phase 12 + Phase 13 = ~17 Weeks

---

## 4. Phase 1 — Foundation & Setup

### 4.1 Application Shell

- Splash screen with logo animation
- First-time setup wizard (5 steps)
- Business registration form
- PIN creation + Master password
- Financial year selection
- Theme selection (Dark / Light / Auto)
- Language selection (English / Hindi / Hinglish labels)

### 4.2 Dashboard (Home Screen)

#### Stats Cards (Top Row)
- Today's Total Sales (₹)
- Today's Total Collection (Cash + UPI + Card)
- Today's GST Collected (₹)
- Today's Expenses (₹)
- Today's Net Profit (₹)
- Pending Payments (₹)
- Outstanding from Customers (₹)
- Outstanding to Suppliers (₹)

#### Charts Section
- Daily Sales Bar Chart (Last 30 days)
- Monthly Sales Line Chart (Last 12 months)
- Category-wise Sales Pie Chart
- GST Collection Bar Chart
- Expense vs Income Comparison Chart
- Top 5 Products Chart
- Top 5 Customers Chart

#### Quick Action Buttons
- ➕ Create Bill
- 👤 New Customer
- 📦 Add Product
- 💰 Add Expense
- 📊 Day Report
- 💾 Backup Now
- 🖨️ Reprint Last Bill
- 📱 WhatsApp Bill

#### Recent Activity Feed
- Last 20 transactions with time
- Color coded (Sale = Green, Expense = Red, Purchase = Blue)
- Click to open any transaction

#### Alerts Panel
- Low stock items (with count)
- Overdue customer payments
- GST return due dates
- Backup reminder
- Subscription/license expiry

### 4.3 Navigation

- Left sidebar (collapsible)
- Keyboard shortcuts for all major screens
- Breadcrumb navigation
- Recent screens history (last 10 screens)
- Pin favorite screens to sidebar
- Search any screen by name (Ctrl+F)

### 4.4 Settings Module (Complete)

#### Business Profile
- Business Name
- Business Type (dropdown: Cyber Cafe / CSC / Print Shop / etc.)
- Owner Name
- GST Number (GSTIN)
- PAN Number
- Aadhar Number (optional)
- CIN / UDYAM Registration Number
- Registered Address (Street, City, State, PIN, Country)
- Correspondence Address (if different)
- Phone (Primary)
- Phone (Secondary)
- Email (Primary)
- Email (Secondary)
- Website
- Business Logo (Upload / Webcam capture)
- Business Stamp Image (Upload)
- Business Signature Image (Upload)
- Bank Name
- Bank Account Number
- IFSC Code
- Account Type (Current / Savings)
- Branch Name
- UPI ID
- UPI QR Code (Auto-generate)

#### Financial Settings
- Financial Year Start (April default)
- Financial Year End
- Currency (INR default)
- Currency Symbol (₹)
- Decimal Places (0 / 2)
- Number Format (Indian: 1,00,000 / International: 100,000)
- Rounding Method (Normal / Up / Down)
- Default Credit Period (days)
- Default Payment Terms

#### Tax Settings
- Default GST Rate
- Default HSN/SAC Code
- Reverse Charge Applicable (Yes/No)
- Composition Scheme (Yes/No)
- Composition Rate
- TDS Applicable (Yes/No)
- TCS Applicable (Yes/No)
- Default TDS Rate
- State Code (for GST)

#### Invoice Settings
- Invoice Prefix (e.g., INV, BILL, GST)
- Invoice Number Format (prefix + year + number)
- Starting Invoice Number
- Reset Each Financial Year (Yes/No)
- Separate series for: Tax Invoice, Cash Memo, Estimate, Credit Note, Debit Note
- Invoice Footer Text (Terms & Conditions)
- Invoice Notes Default Text
- Payment Terms Default Text
- Show Bank Details on Invoice (Yes/No)
- Show QR Code on Invoice (Yes/No)
- Show Digital Signature (Yes/No)
- Show Watermark (Yes/No)
- Watermark Text

#### Printer Settings
- Default Printer Name (Windows printer list)
- Default Paper Size (A4 / A5 / Thermal 80mm / Thermal 58mm / Legal)
- Number of Copies (default)
- Print Preview Before Print (Yes/No)
- Thermal Printer COM Port
- Thermal Printer Baud Rate

#### Backup Settings
- Auto Backup (Yes/No)
- Backup Frequency (Daily / Weekly / Monthly)
- Backup Time (HH:MM)
- Backup Folder Path (Windows folder picker)
- Keep Backup Count (last N backups)
- Compress Backup (Yes/No)
- Backup to Cloud (Yes/No)
- Cloud Backup Provider (Google Drive / Dropbox / Custom FTP)

#### Appearance Settings
- Theme (Light / Dark / System)
- Accent Color (12 presets + custom hex)
- Font Size (Small / Medium / Large)
- Table Row Height
- Sidebar Width
- Animation Speed (Fast / Normal / None)

#### Notification Settings
- Low Stock Alert Threshold
- Payment Overdue Alert (days)
- GST Return Reminder (days before)
- Backup Reminder (hours)
- Auto-dismiss notifications (Yes/No)

#### Security Settings
- Master Password
- PIN (4/6 digit)
- Auto-Lock After Inactivity (minutes)
- Lock on Minimize (Yes/No)
- Delete Confirmation Always (Yes/No)
- Audit Trail (Yes/No)
- Failed Login Max Attempts
- Session Timeout

---

## 5. Phase 2 — GST Billing System (Full)

### 5.1 Bill Types Supported

| Bill Type | Description | GST Applicable |
|---|---|---|
| Tax Invoice | Standard GST invoice for GST registered customers | Yes |
| Cash Memo | Bill for unregistered/walk-in customers | Optional |
| Proforma Invoice | Quote before actual sale | Optional |
| Estimate / Quotation | Price estimate only | No |
| Sales Order | Confirmed order before delivery | No |
| Delivery Challan | Goods movement without invoice | No |
| Credit Note | Goods return from customer | Yes (negative) |
| Debit Note | Return to supplier | Yes (negative) |
| Purchase Bill | Bill received from supplier | Yes (input credit) |
| Expense Bill | Non-inventory expense | Yes (input credit) |
| Receipt Voucher | Payment received | No |
| Payment Voucher | Payment made | No |
| Advance Receipt | Advance from customer | Yes (GST on advance) |
| Export Invoice | Zero-rated supply | Yes (0%) |

### 5.2 Invoice Creation Screen

#### Header Section
- Bill Type (dropdown)
- Bill Number (auto + manual override)
- Bill Date (date picker)
- Bill Time (auto)
- Due Date (auto calculate from credit period)
- Place of Supply (State dropdown)
- Reference Number (optional)
- Order Number (link to sales order)

#### Customer Section
- Customer Search (name / phone / GST)
- Quick Add Customer (inline)
- Customer Name
- Customer GSTIN
- Customer PAN
- Customer Phone
- Customer Email
- Billing Address (pre-filled from customer)
- Shipping Address (same as billing / different)
- Customer Outstanding (shown as alert)
- Customer Credit Limit (shown)

#### Items Table

Each row contains:
- # (serial number)
- Item Search (name / SKU / barcode)
- Item Description (editable)
- HSN/SAC Code (auto-fill)
- Unit (Nos / Kg / Ltr / Page / Hr / etc.)
- Qty
- Rate (₹)
- Discount % (column level)
- Discount ₹ (column level)
- Taxable Amount (auto)
- GST Rate (0% / 5% / 12% / 18% / 28%)
- CGST % + Amount (for intra-state)
- SGST % + Amount (for intra-state)
- IGST % + Amount (for inter-state)
- CESS % + Amount
- Total Amount (auto)
- Action (delete / duplicate row)

#### Item Row Features
- Inline editing
- Barcode scanner input (USB scanner or keyboard scan)
- Auto stock check (warn if out of stock)
- Auto price suggestion from price list
- Free item quantity support (qty vs free qty)
- Batch number selection
- Expiry date selection
- Serial number input

#### Footer Section

**Discount Block**
- Item-level discount (in table)
- Bill-level flat discount (₹)
- Bill-level percentage discount (%)
- Coupon code discount
- Loyalty points discount

**Charges Block**
- Freight / Shipping charges
- Packaging charges
- Loading/Unloading charges
- Other charges (custom label)
- Each charge: Taxable or Non-taxable

**Tax Summary Block**
- GST-wise breakup table:
  - 0%, 5%, 12%, 18%, 28%
  - CGST / SGST / IGST (auto based on state)
  - CESS
  - Total Tax
- Round Off (auto / manual)
- TDS deducted (if applicable)
- TCS collected (if applicable)

**Amount Block**
- Sub Total (before tax)
- Total Discount
- Taxable Amount
- Total Tax
- **Grand Total (₹)**
- Amount in Words (Indian English: "Rupees Two Thousand Five Hundred Only")

**Payment Block**
- Cash Received (₹)
- Balance Due (auto)
- Change Return (auto)
- Multi-payment mode:
  - Cash
  - UPI (show UPI ID + QR)
  - Card (enter last 4 digits)
  - Bank Transfer / NEFT / RTGS
  - Cheque (enter cheque no.)
  - Credit (add to customer outstanding)
  - Advance Adjustment

**Narration Block**
- Internal notes (not printed)
- Customer-visible notes (printed)
- Terms & Conditions (pre-fill from settings)

### 5.3 Bill Actions (After Creation)

- Save as Draft
- Save & Print
- Save & PDF
- Save & WhatsApp
- Save & Email
- Save & SMS
- Preview
- Duplicate Bill
- Convert to: (Estimate → Invoice → Delivery Challan)
- Cancel Bill (with reason)
- Return / Credit Note (full or partial)
- Amend Bill (with original reference — for GST)
- Download JSON (for e-invoice)

### 5.4 Bill List Screen

- Filterable by: Date range, Bill type, Customer, Amount range, Payment status, GST status
- Searchable by: Bill number, Customer name, Phone, Amount, Item name
- Columns: Bill No, Date, Customer, Amount, Tax, Status, Payment, Actions
- Bulk actions: Print, PDF, Delete, Export, WhatsApp
- Status badges: Draft, Active, Cancelled, Returned, Partially Paid, Fully Paid
- Pagination with configurable page size
- Sort by any column

### 5.5 GST Calculation Engine

- Auto-detect CGST+SGST vs IGST based on Place of Supply vs Business State
- Reverse Charge Mechanism (RCM) support
- Composition Dealer billing (no tax on bill, only note)
- Exempt / Nil-rated / Zero-rated / Non-GST supply support
- Multiple tax slabs in same bill
- Tax on MRP calculation
- Inclusive tax calculation (back-calculate from MRP)
- Cess calculation (additional on 28%)
- GST on advances (Section 31)
- GST on freight (separate HSN 9965)

### 5.6 HSN/SAC Master

- Built-in HSN code database (5000+ codes)
- SAC code database (service codes)
- Search by description or code
- Default HSN per product auto-fill
- Cyber Café specific SAC codes pre-loaded:
  - 998314 — Data Processing
  - 998315 — Computer facility management
  - 99831 — IT Infrastructure services
  - 9984 — Telecommunication services
  - 998552 — Internet café services

### 5.7 Price List System (Tally-style)

- Multiple price lists (e.g., Retail, Wholesale, Government, Student)
- Price list validity dates
- Customer-wise price list assignment
- Quantity-based pricing (slab pricing: 1–10 = ₹10, 11–50 = ₹9, 51+ = ₹8)
- Date-based price changes
- Currency-wise prices (for export)
- Price list override at billing time

---

## 6. Phase 3 — Tally-Style Accounting Engine

> This is the complete accounting core — every feature from Tally Prime reproduced.

### 6.1 Chart of Accounts (Groups & Ledgers)

#### Pre-defined Account Groups (Tally-Compatible)

```
Assets
├── Fixed Assets
│   ├── Land & Buildings
│   ├── Plant & Machinery
│   ├── Furniture & Fixtures
│   ├── Computers & Peripherals
│   └── Vehicles
├── Current Assets
│   ├── Cash-in-Hand
│   │   └── Cash Account (default)
│   ├── Bank Accounts
│   ├── Loans & Advances (Asset)
│   ├── Sundry Debtors
│   ├── Stock-in-Trade
│   ├── Deposits (Asset)
│   └── Other Current Assets
└── Investments

Liabilities
├── Capital Account
│   ├── Capital
│   └── Drawings
├── Current Liabilities
│   ├── Sundry Creditors
│   ├── Duties & Taxes
│   │   ├── CGST Payable
│   │   ├── SGST Payable
│   │   ├── IGST Payable
│   │   ├── CESS Payable
│   │   ├── TDS Payable
│   │   └── TCS Payable
│   ├── Loans (Liability)
│   └── Provisions
└── Loans (Long-term)

Income
├── Direct Income
│   ├── Sales Accounts
│   └── Service Income
└── Indirect Income
    ├── Interest Income
    ├── Discount Received
    └── Other Income

Expenses
├── Direct Expenses
│   ├── Purchase Accounts
│   └── Direct Costs
└── Indirect Expenses
    ├── Salary & Wages
    ├── Rent
    ├── Electricity
    ├── Internet Charges
    ├── Telephone
    ├── Repair & Maintenance
    ├── Stationery
    ├── Advertisement
    ├── Transport
    └── Other Expenses
```

#### Ledger Master Features
- Create unlimited ledgers
- Assign to account group
- Opening balance (Dr/Cr)
- Credit period (days)
- Credit limit (₹)
- GST Registration (GSTIN, type: Regular/Composition/Unregistered/Consumer)
- PAN
- Default mailing address
- Bank details (for payments)
- TDS applicable (Yes/No + Nature of Payment)
- Cost center allocation
- Bill-by-bill details (Yes/No)
- Interest calculation applicable

### 6.2 Voucher Types (Complete)

| Voucher Type | Dr/Cr Rule | Example |
|---|---|---|
| **Receipt** | Dr: Cash/Bank, Cr: Debtor/Income | Customer payment |
| **Payment** | Dr: Expense/Creditor, Cr: Cash/Bank | Pay rent, pay supplier |
| **Sales** | Dr: Debtor/Cash, Cr: Sales + GST | Sell goods/services |
| **Purchase** | Dr: Purchase + GST, Cr: Creditor | Buy goods from supplier |
| **Credit Note** | Reverse of Sales | Customer returns |
| **Debit Note** | Reverse of Purchase | Return to supplier |
| **Journal** | Dr & Cr any ledger | Adjustments, depreciation |
| **Contra** | Between cash & bank only | Cash deposit, withdrawal |
| **Stock Journal** | Between stock groups | Stock transfer, adjustment |
| **Memorandum** | Not posted to books | Reminders only |
| **Optional** | Tentative (not posted) | Pending transactions |
| **Reversing Journal** | Auto-reverses on given date | Provisions |
| **Manufacturing Journal** | BOM-based production | If manufacturing |

#### Common Voucher Features (All Types)
- Voucher date
- Voucher number (auto + manual)
- Narration
- Cost center allocation
- Bill-by-bill reference
- Project/job reference
- Attachment (PDF, image)
- Tags
- Pending approval flag
- Verified by (user)
- Created by (user)
- Modified by (user) with timestamp

### 6.3 Bill-by-Bill Details (Tally Feature)

- Each bill is individually tracked
- Outstanding bill list per ledger
- Receipts / Payments linked to specific bills
- Automatic aging analysis:
  - 0-30 days (current)
  - 31-60 days (1 month overdue)
  - 61-90 days (2 months overdue)
  - 91-180 days (3-6 months)
  - 181-365 days (6-12 months)
  - 365+ days (more than 1 year)
- Partial payment tracking
- Full & final settlement

### 6.4 Cost Centers & Cost Categories (Tally Feature)

- Create unlimited cost centers (e.g., Printing Dept, Internet Dept, Photocopy Dept)
- Cost categories (e.g., Revenue, Capital)
- Allocate every voucher entry to cost center
- Cost center-wise P&L
- Cost center-wise balance sheet
- Budget vs actual per cost center

### 6.5 Budget & Control (Tally Feature)

- Budget creation (per financial year)
- Budget type: On Net Transactions / On Opening Balance
- Period: Monthly / Quarterly / Yearly
- Ledger-wise budget
- Group-wise budget
- Cost center-wise budget
- Budget vs actual comparison report
- Budget variance alerts (when 80% consumed)
- Under-utilized budget report

### 6.6 Interest Calculation (Tally Feature)

- Simple Interest Calculation
- Compound Interest Calculation
- Interest on outstanding bills
- Interest on delayed payment
- Debit balance interest
- Credit balance interest
- Interest rate per ledger
- Interest voucher auto-creation
- Interest report

### 6.7 Bank Reconciliation (Tally Feature)

- Import bank statement (CSV / Excel / OFX)
- Auto-match transactions
- Manual match
- Unmatched transactions list
- Bank balance vs book balance
- Reconciliation statement print
- BRS (Bank Reconciliation Statement) report
- Date-wise bank balance report

### 6.8 Multi-Currency (Tally Feature)

- Add unlimited currencies
- Currency: USD, EUR, GBP, AED, SGD, etc.
- Exchange rate: Fixed / Date-based
- Auto exchange rate (optional: fetch from RBI)
- Forex gain/loss calculation
- Multi-currency reports
- Revaluation of foreign balances

### 6.9 Fixed Assets & Depreciation (Tally Feature)

- Fixed asset register
- Asset categories (Computer / Furniture / Vehicle / etc.)
- Purchase date, purchase price
- Depreciation method:
  - Straight Line Method (SLM)
  - Written Down Value (WDV)
  - Units of Production
- Depreciation rate
- Useful life (years)
- Salvage value
- Auto depreciation voucher
- Asset disposal entry
- Asset register report
- Depreciation schedule
- Net book value report

### 6.10 Opening Balance Import

- Import from Tally (.xml export)
- Import from Excel (template provided)
- Import from previous year's closing
- Ledger opening balances
- Stock opening balances
- Customer outstanding opening
- Supplier outstanding opening
- Balance verification before import

### 6.11 Year-End Processing

- Trial balance freeze for closed year
- Profit/Loss transfer to Capital
- Opening balance carry-forward (new year)
- Previous year data view (read-only)
- Multi-year comparison

---

## 7. Phase 4 — CorelDRAW-Style Invoice Designer

> Full drag-and-drop invoice template designer — user can design their own bill format.

### 7.1 Template Designer Canvas

- **Canvas size selector** (A4 / A5 / A3 / Letter / Thermal 80mm / Thermal 58mm / Custom)
- **Orientation** (Portrait / Landscape)
- **Margin settings** (Top / Bottom / Left / Right in mm)
- **Page background** (White / Color / Gradient / Pattern / Custom image)
- **Grid overlay** (toggleable — like CorelDRAW grid)
- **Ruler** (horizontal + vertical — like CorelDRAW)
- **Guide lines** (drag from ruler)
- **Snap to grid** (Yes/No)
- **Snap to guides** (Yes/No)
- **Snap to elements** (Yes/No)
- **Zoom** (50% to 400%)
- **Pan** (hold Space + drag — like CorelDRAW)

### 7.2 Design Elements (Toolbar)

#### Text Elements
- Static Text Box (type anything)
- Dynamic Data Field (auto-fills from invoice data):
  - {BUSINESS_NAME}
  - {BUSINESS_GST}
  - {BUSINESS_ADDRESS}
  - {BUSINESS_PHONE}
  - {INVOICE_NUMBER}
  - {INVOICE_DATE}
  - {INVOICE_DUE_DATE}
  - {CUSTOMER_NAME}
  - {CUSTOMER_GSTIN}
  - {CUSTOMER_ADDRESS}
  - {SUBTOTAL}
  - {TOTAL_TAX}
  - {GRAND_TOTAL}
  - {AMOUNT_IN_WORDS}
  - {BALANCE_DUE}
  - {PAYMENT_TERMS}
  - {NOTES}
  - {TERMS_CONDITIONS}
  - {BANK_NAME}
  - {BANK_ACCOUNT}
  - {IFSC}
  - {UPI_ID}
  - Custom fields

#### Shape Elements
- Rectangle (with border, fill, radius)
- Line (horizontal, vertical, diagonal)
- Divider / HR line
- Circle / Ellipse
- Triangle
- Star
- Custom polygon

#### Image Elements
- Business Logo (from settings auto-insert)
- Signature Image
- Stamp Image
- Custom image upload
- Background image (watermark-style, opacity)

#### Table Elements
- Items Table (drag to position, configure columns)
  - Show/hide each column
  - Column width adjustment
  - Header row style
  - Alternate row colors
  - Border style (inner / outer / none)
  - Font per section
- Tax Summary Table
- Payment Details Table
- Bank Details Table
- Blank Custom Table

#### Dynamic Components
- QR Code (UPI payment QR — auto-generate)
- GST QR Code (IRN-based — for e-invoice)
- Barcode (invoice number / custom)
- Digital Signature Box (with draw-and-sign pad)
- Stamp Box (round/square stamp)

### 7.3 Element Properties Panel (Right Sidebar)

When any element is selected, right panel shows:

**Position & Size**
- X position (mm from left)
- Y position (mm from top)
- Width (mm)
- Height (mm)
- Rotation (degrees)
- Lock aspect ratio (Yes/No)
- Lock position (Yes/No — prevent accidental move)

**Typography (for text elements)**
- Font family (all Windows system fonts listed)
- Font size (6pt to 72pt)
- Font weight (Thin / Light / Regular / Medium / SemiBold / Bold / ExtraBold / Black)
- Font style (Normal / Italic / Oblique)
- Text decoration (Underline / Strikethrough)
- Letter spacing (kerning)
- Line height
- Text transform (UPPERCASE / lowercase / Capitalize / None)
- Text align (Left / Center / Right / Justify)
- Text color (color picker + hex input)
- Background color of text box
- Padding (inside text box)

**Fill & Stroke (for shapes)**
- Fill type: None / Solid / Linear Gradient / Radial Gradient / Pattern
- Fill color
- Gradient start color, end color, angle
- Stroke (border) width
- Stroke color
- Stroke style (Solid / Dashed / Dotted / Double)
- Corner radius (for rectangles)

**Image Properties**
- Source image
- Fit mode: Contain / Cover / Fill / Stretch / Original
- Opacity (0–100%)
- Brightness / Contrast adjustment
- Grayscale (Yes/No)

**Layer Order**
- Bring to Front
- Send to Back
- Bring Forward (one step)
- Send Backward (one step)
- Layer number display

### 7.4 Designer Tools (Top Toolbar — like CorelDRAW)

| Tool | Shortcut | Description |
|---|---|---|
| Select (Arrow) | V | Select + move elements |
| Text Tool | T | Add text box |
| Rectangle Tool | R | Draw rectangle |
| Line Tool | L | Draw line |
| Image Tool | I | Insert image |
| Table Tool | Tab | Insert table |
| QR Tool | Q | Insert QR code |
| Pan Tool | Space | Pan canvas |
| Zoom In | Ctrl++ | Zoom in |
| Zoom Out | Ctrl+- | Zoom out |
| Fit to Page | Ctrl+0 | Fit canvas to window |
| Undo | Ctrl+Z | Undo last action |
| Redo | Ctrl+Y | Redo action |
| Copy | Ctrl+C | Copy element |
| Paste | Ctrl+V | Paste element |
| Duplicate | Ctrl+D | Duplicate element |
| Delete | Del | Delete element |
| Select All | Ctrl+A | Select all elements |
| Group | Ctrl+G | Group selected elements |
| Ungroup | Ctrl+Shift+G | Ungroup |
| Align Left | | Align selected elements left |
| Align Right | | Align selected elements right |
| Align Center | | Center horizontally |
| Align Middle | | Center vertically |
| Distribute Evenly | | Equal spacing |

### 7.5 Template Library (Pre-built Templates)

**20+ built-in professional templates:**

1. Classic GST Invoice (blue header)
2. Modern Minimal (white + black)
3. Cyber Café Special (tech design)
4. CSC Center Template (government style)
5. Print Shop Invoice (print-themed)
6. Boutique Style (colorful)
7. Dark Professional (dark header)
8. Orange Business
9. Green Fresh
10. Red Corporate
11. Government Style (formal)
12. Thermal Print (80mm — compact)
13. Thermal Print (58mm — mini)
14. A5 Compact Invoice
15. Cash Memo (simple)
16. Delivery Challan Template
17. Quotation / Estimate Template
18. Credit Note Template
19. Purchase Order Template
20. Letterhead Template

**Template Actions:**
- Select template → auto-apply to canvas
- Edit any built-in template
- Save as custom template (unlimited)
- Export template as file (share with other shops)
- Import template from file
- Delete custom template
- Preview template with dummy data

### 7.6 Watermark System

- Text watermark (e.g., "ORIGINAL", "DUPLICATE", "CANCELLED", "PAID")
- Image watermark (company logo as watermark)
- Watermark opacity (5%–80%)
- Watermark position (Center / Corner)
- Watermark rotation angle
- Different watermark per bill copy (Original / Duplicate / Triplicate)
- "PAID" auto-watermark when bill fully paid
- "CANCELLED" auto-watermark when bill cancelled

### 7.7 Multi-Copy Print Design

- Define how many copies: Original / Duplicate / Triplicate
- Each copy can have different:
  - Watermark text
  - Header label ("For Customer" / "For Office" / "For Accounts")
  - Color (print first in color, rest in grayscale)
  - Page (add/remove sections per copy)

---

## 8. Phase 5 — Inventory & Supplier Management

### 8.1 Product/Service Master

- Product or Service type
- Product Name
- SKU (Stock Keeping Unit — auto or manual)
- Barcode (auto-generate EAN-13 / Code-128 / QR)
- Category / Sub-category
- Brand
- Unit of Measurement (Nos / Kg / Ltr / Page / Hr / Set / Box / etc.)
- Description (rich text)
- Product Image (multiple — up to 5)
- HSN / SAC Code
- Purchase Price (₹)
- Selling Price (₹)
- MRP (₹)
- Minimum Selling Price (₹) (warning if sold below)
- GST Rate (%)
- Tax Inclusive or Exclusive flag
- Opening Stock Qty
- Opening Stock Value
- Minimum Stock Level (reorder point)
- Maximum Stock Level
- Reorder Qty
- Supplier (default)
- Location / Rack / Shelf
- Expiry Tracking (Yes/No)
- Batch Tracking (Yes/No)
- Serial Number Tracking (Yes/No)
- Warranty (days)
- Weight / Dimensions
- Notes

**Cyber Café Specific Services (Pre-loaded):**
- Internet Usage (per hour / per minute)
- Printing — Color A4 (₹ per page)
- Printing — B&W A4 (₹ per page)
- Printing — Color A3
- Printing — B&W A3
- Xerox — B&W A4
- Xerox — Color A4
- Lamination — A4 / A3
- Spiral Binding
- Hard Binding
- Passport Size Photo (set of 4/6/8)
- ID Card Making
- Scanning (per page)
- Typing (per page)
- Computer Rental (per hour)
- Aadhaar New Enrollment
- Aadhaar Update / Correction
- Aadhaar Address Update
- PAN Card Application
- PAN Card Correction
- Voter ID Application
- Driving License Apply
- Income Certificate
- Caste Certificate
- Domicile Certificate
- Birth / Death Certificate
- IRCTC Train Ticket
- Air Ticket Booking
- Bus Ticket
- Hotel Booking
- Passport Application
- Passport Renewal
- Visa Application
- Courier / Speed Post
- Mobile Recharge
- DTH Recharge
- Electricity Bill Payment
- Water Bill Payment
- Gas Bill Payment
- Internet Bill Payment
- Insurance Premium
- LIC Premium
- Loan EMI Payment
- School Fees
- College Fees
- Education Loan
- NPS / PPF Account
- Pradhan Mantri Yojana Forms
- Jan Dhan Account Opening
- PM Kisan Registration
- Udyam Registration
- GST Registration
- Income Tax Return Filing
- TDS / Form-16
- EPFO Services
- ESI Services

### 8.2 Category & Sub-Category

- Unlimited categories
- Nested sub-categories
- Category-wise GST rate default
- Category-wise HSN/SAC
- Category icon
- Category color tag
- Category-wise reports

### 8.3 Stock Management

- Real-time stock levels
- Stock-in (Purchase entry)
- Stock-out (Sales entry)
- Stock adjustment (manual correction)
- Stock transfer (between locations)
- Stock journal (internal movement)
- Opening stock entry
- Physical stock verification vs book stock
- Stock discrepancy report
- Dead stock report (not sold in N days)
- Fast-moving / slow-moving report
- Stock aging analysis

### 8.4 Batch & Expiry Tracking

- Batch number creation
- Manufacturing date
- Expiry date
- Batch-wise selling (FIFO / LIFO / Manual)
- Near-expiry alerts (configurable days before)
- Expired stock report
- Batch-wise profit report
- Batch transfer between locations

### 8.5 Multi-Location / Godown (Tally Feature)

- Main Godown (default)
- Create unlimited storage locations
- Location-wise stock report
- Inter-location stock transfer
- Location-wise valuation
- Godown-wise stock summary

### 8.6 Stock Valuation Methods

- FIFO (First In First Out)
- LIFO (Last In First Out)
- Average Cost (Weighted Average)
- Standard Cost
- Monthly Average
- At Zero Cost (for free items)

### 8.7 Bill of Materials (BOM)

- For businesses that assemble products
- Create BOM for finished goods
- List raw material quantities
- Production voucher from BOM
- Auto-deduct raw materials on production
- BOM-wise cost calculation
- Production report

### 8.8 Supplier Module

- Unlimited suppliers
- Supplier name
- Supplier GSTIN
- Supplier PAN
- Supplier phone / email
- Supplier address
- Default payment terms
- Credit period
- Credit limit
- Bank details (for payments)
- Supplier category
- Supplier rating
- Blacklist option
- Supplier-wise purchase history
- Supplier ledger
- Supplier outstanding
- Supplier aging report
- Supplier payment schedule
- Supplier statement

### 8.9 Purchase Management

- Purchase order creation
- Purchase order → Purchase bill conversion
- Purchase bill entry
- Purchase return (Debit Note)
- Purchase register
- Supplier-wise purchase report
- Item-wise purchase report
- Purchase vs sales comparison

---

## 9. Phase 6 — Customer & CRM Module

### 9.1 Customer Master (Complete)

- Customer ID (auto)
- Customer Code (custom prefix)
- Customer Type (Business / Individual / Government / Student / NGO)
- Salutation (Mr / Mrs / Ms / Dr / Er / Adv / CA)
- First Name / Last Name
- Business / Company Name
- GST Number (GSTIN — validate format)
- PAN Number (validate format)
- Aadhaar Number (last 4 only — for verification)
- Date of Birth (for individuals)
- Anniversary Date
- Gender
- Phone (Primary)
- Phone (Alternate)
- WhatsApp Number
- Email (Primary)
- Email (Alternate)
- Address Line 1
- Address Line 2
- City
- State (dropdown — all 28 states + UTs)
- PIN Code
- Country
- Shipping Address (if different from billing)
- Customer Group / Category
- Price List assigned
- Credit Period (days)
- Credit Limit (₹)
- TDS Applicable
- Customer Photo (optional)
- Customer Documents (Aadhaar, PAN image upload)
- Notes / Remarks
- Tags (multi-select)
- Referred by
- Source (Walk-in / Phone / Online / Referral)
- Registration Date
- Active / Inactive status
- Blacklist (Yes/No + Reason)
- Favourite (Yes/No)

### 9.2 Customer Dashboard (Per Customer)

- Total Purchase (all time)
- Total Purchase (this year)
- Total Purchase (this month)
- Outstanding amount (₹)
- Last Purchase date
- Last Payment date
- Average bill value
- Number of visits
- Loyalty points balance
- Documents on file

### 9.3 Customer Ledger (Tally-Style)

- Date-wise all transactions
- Opening balance
- Sales (with bill numbers)
- Receipts/Payments
- Credit notes
- Interest charges
- Closing balance
- Filter by date range
- Print / PDF / Excel export
- Send by WhatsApp / Email

### 9.4 Customer Statement

- Outstanding bills list
- Bill-wise aging
- Summary statement (with totals)
- Detailed statement (line by line)
- Date range filter
- Auto-calculated interest if configured
- Print / Email / WhatsApp

### 9.5 Customer Loyalty Points

- Points earning rules: ₹X spent = Y points
- Minimum bill for earning
- Redemption rules: Z points = ₹1 discount
- Maximum redemption % per bill
- Points validity (days)
- Points history per customer
- Points balance on billing screen
- Birthday bonus points
- Anniversary bonus points
- Loyalty report (all customers)

### 9.6 Duplicate Detection

- Check phone number on creation
- Check GSTIN on creation
- Check name similarity (fuzzy match)
- Merge duplicate customers
- Merge transaction history

### 9.7 Customer Import / Export

- Import from Excel (template download)
- Import from CSV
- Import from Tally XML
- Export to Excel
- Export to CSV
- Export to PDF (list)
- Export to VCF (contacts)

---

## 10. Phase 7 — GST Compliance & Returns

### 10.1 E-Invoice (IRP Integration)

- E-Invoice applicable threshold check (current: ₹5 Cr turnover)
- IRN (Invoice Reference Number) generation
- E-invoice API integration (NIC / IRP sandbox + production)
- QR code generation from IRN
- Bulk e-invoice generation
- E-invoice cancellation (within 24 hours rule)
- Amended e-invoice
- E-invoice JSON export (schema v1.1)
- IRN status check
- Failed e-invoice retry queue
- E-invoice register

### 10.2 E-Way Bill

- E-Way Bill generation (for goods movement > ₹50,000)
- E-Way Bill number auto-attach to invoice
- Vehicle number entry
- Transporter name / GSTIN
- Place of delivery
- Distance calculation
- E-Way Bill validity tracking
- E-Way Bill extension
- E-Way Bill cancellation
- Bulk E-Way Bill generation
- E-Way Bill register / report

### 10.3 GSTR-1 (Monthly/Quarterly Outward Supply)

**Auto-populate from sales data:**
- B2B supplies (GST registered customers)
- B2C large (inter-state > ₹2.5 lakh)
- B2C small (remaining)
- Export with payment
- Export without payment
- Nil / Exempt / Non-GST supplies
- Credit / Debit notes
- Amendments (Tables 9A, 9B, 9C)
- HSN summary
- Document summary
- GSTR-1 preview
- GSTR-1 JSON download (for portal upload)
- GSTR-1 Excel download
- GSTR-1 reconciliation with portal data

### 10.4 GSTR-3B (Monthly Summary Return)

- Auto-calculate from vouchers
- Outward taxable supply (excluding zero-rated)
- Outward zero-rated supply
- Inward supplies liable to reverse charge
- Non-GST outward supply
- ITC available (from purchase)
- ITC reversed
- Net ITC
- Tax payable vs ITC vs cash ledger
- GSTR-3B preview
- GSTR-3B JSON export
- Late fee calculation

### 10.5 GSTR-2A / 2B Reconciliation

- Import 2A/2B from GST portal (JSON)
- Compare with purchase entries
- Matched invoices
- Unmatched in 2A but not in books
- Unmatched in books but not in 2A
- Reconciliation report
- Action on mismatches (contact supplier, amendment)

### 10.6 GSTR-4 (Composition Dealer Quarterly)

- For composition dealers only
- Inward supplies auto-populate
- Outward supplies (aggregate)
- Tax payable
- JSON export

### 10.7 GSTR-9 (Annual Return)

- Auto-populate from all vouchers
- Financial year summary
- Turnover reconciliation
- ITC reconciliation
- Tax paid summary
- GSTR-9 preview
- GSTR-9 JSON/Excel export

### 10.8 GST Ledger Reports

- Electronic Cash Ledger
- Electronic Credit Ledger
- Electronic Liability Ledger
- IGST / CGST / SGST balance tracking
- Tax payment entries
- Utilization of ITC

### 10.9 TDS Management (Tally Feature)

- TDS applicable flag per ledger
- Nature of Payment (Section 194C, 194J, 194H, etc.)
- TDS rate per nature
- TDS threshold per nature
- TDS deduction auto at voucher entry
- TDS payable ledger auto-update
- TDS payment voucher
- Form 26Q data generation
- Form 16A generation
- TDS return data export
- TDS register
- TDS payable report
- TDS deducted report

### 10.10 TCS Management

- TCS applicable flag per ledger
- TCS rate
- TCS collection auto at billing
- TCS payable tracking
- TCS payment voucher
- Form 27EQ data
- TCS register

---

## 11. Phase 8 — Reports & Analytics Engine

### 11.1 Accounting Reports (Tally-Style)

| Report Name | Description |
|---|---|
| **Trial Balance** | All ledger debit/credit balances |
| **Balance Sheet** | Assets vs Liabilities (Schedule III) |
| **Profit & Loss Account** | Income vs Expense (Trading + P&L) |
| **Trading Account** | Gross profit calculation |
| **Cash Flow Statement** | Operating / Investing / Financing |
| **Fund Flow Statement** | Change in working capital |
| **Ratio Analysis** | Current ratio, Quick ratio, Gross profit %, Net profit %, Return on investment |
| **Day Book** | All vouchers for a date |
| **Cash Book** | Cash account transactions |
| **Bank Book** | Bank account transactions |
| **Ledger Report** | Transactions for any ledger |
| **Group Summary** | Group-wise balance |
| **Statements of Accounts** | Customer/Supplier statement |
| **Outstanding Receivables** | Customer-wise outstanding |
| **Outstanding Payables** | Supplier-wise outstanding |
| **Aging Analysis** | Bills overdue 0-30, 31-60, 61-90, 90+ days |
| **Bill Register** | All bills in a period |
| **Budget vs Actual** | Budget comparison |
| **Cost Center Report** | Cost center-wise P&L |
| **Interest Register** | Interest charged/earned |
| **Bank Reconciliation** | Bank vs books comparison |
| **Depreciation Report** | Asset depreciation schedule |

### 11.2 GST Reports

| Report | Use |
|---|---|
| GSTR-1 | Outward supply report |
| GSTR-3B | Monthly summary |
| GSTR-2A Reconciliation | ITC mismatch |
| GST Summary | CGST/SGST/IGST totals |
| HSN Summary | HSN-wise supply |
| GST Receivable | Reverse charge liability |
| GST Payable | Net GST to pay |
| E-Invoice Register | All IRN records |
| E-Way Bill Register | All EWB records |
| GST Audit Report | All transactions for audit |

### 11.3 Sales Reports

- Daily Sales Report
- Weekly Sales Report
- Monthly Sales Report
- Yearly Sales Report
- Custom Date Range Sales
- Product-wise Sales
- Category-wise Sales
- Customer-wise Sales
- Salesperson-wise Sales
- Payment Mode-wise Sales
- Bill type-wise Sales
- Discount Report
- Cancelled Bills Report
- Return Bills Report
- Sales Comparison (Month over Month, Year over Year)

### 11.4 Purchase Reports

- Daily / Weekly / Monthly Purchase
- Supplier-wise Purchase
- Product-wise Purchase
- Category-wise Purchase
- GST Input Credit Report
- Purchase Return Report
- Purchase Comparison

### 11.5 Inventory Reports

- Stock Summary (all items)
- Stock Detail (batch/serial-wise)
- Stock Ledger (item transaction history)
- Low Stock Report
- Out of Stock Report
- Dead Stock Report (not sold in N days)
- Expiry Report
- Negative Stock Report
- Stock Aging
- Stock Valuation
- Reorder Report
- Profit Margin Report (item-wise)
- Opening vs Closing Stock

### 11.6 Customer Reports

- Customer List
- Customer Outstanding
- Customer Aging
- Customer Ledger
- Customer Statement
- Customer Loyalty Points
- New Customer Report
- Inactive Customer Report
- Top Customers by Sales
- Customer-wise Profitability

### 11.7 Expense Reports

- Daily / Monthly / Yearly Expenses
- Category-wise Expenses
- Vendor-wise Expenses
- GST on Expenses
- Expense Comparison

### 11.8 Profit Reports

- Gross Profit Report
- Net Profit Report
- Product-wise Profit
- Customer-wise Profit
- Date-wise Profit
- Profit Comparison

### 11.9 Employee & Payroll Reports

- Employee List
- Attendance Report
- Salary Statement
- Salary Register
- PF / ESI / PT Report
- TDS on Salary
- Leave Report

### 11.10 Report Features (All Reports)

- Date range filter
- Multiple export formats:
  - PDF (A4 / A5)
  - Excel (.xlsx)
  - CSV
  - Print
- Charts embedded in reports (bar, line, pie)
- Sort by any column
- Group by options
- Sub-totals and grand totals
- Comparison columns (vs last month / last year)
- Report bookmarks (save filter settings)
- Schedule reports (email daily/weekly)
- Report sharing (PDF link)

---

## 12. Phase 9 — Payroll & HR Module

> For businesses with employees — full Tally-style payroll.

### 12.1 Employee Master

- Employee ID (auto)
- Employee Name
- Designation / Post
- Department
- Date of Joining
- Date of Birth
- Gender
- Aadhaar Number
- PAN Number
- Bank Account + IFSC
- Bank Name
- UPI ID
- PF Account Number
- ESI Number
- UAN (Universal Account Number)
- Address
- Emergency Contact
- Documents (photo, ID, address proof)
- Salary structure assignment
- Leave policy assignment

### 12.2 Salary Structure

- Create multiple pay structures
- Components:
  - Basic Salary
  - HRA (House Rent Allowance)
  - DA (Dearness Allowance)
  - Conveyance Allowance
  - Medical Allowance
  - Special Allowance
  - Overtime Allowance
  - Other Allowances (custom)
  - PF (Provident Fund — 12% of Basic)
  - ESI (Employee State Insurance — 0.75%)
  - Professional Tax (state-wise)
  - TDS on Salary (per Form 16)
  - LWF (Labour Welfare Fund)
  - Advance Deduction
  - Loan Deduction
  - Other Deductions (custom)
- Gross Salary (auto)
- Net Salary (auto)
- Formula-based components

### 12.3 Attendance Module

- Daily attendance marking (Present / Absent / Half-day / Leave)
- Monthly attendance sheet
- Attendance import from CSV
- Late coming (early arrival vs standard time)
- Early going
- Overtime calculation
- Holiday master (national + state holidays)
- Weekly off setting (Saturday / Sunday / custom)
- Attendance report

### 12.4 Leave Management

- Leave types: Casual / Medical / Earned / Maternity / LOP (Loss of Pay)
- Leave balance per employee
- Leave application
- Leave approval
- Leave encashment
- Leave carry-forward (year end)
- Leave report

### 12.5 Salary Processing

- Monthly salary run (one click)
- Individual salary processing
- Salary revision
- Arrears calculation
- Salary on hold
- Final settlement (when employee leaves)
- Salary slip generation (PDF)
- Salary payment voucher (linked to accounting)
- Bank transfer list (for bulk NEFT)

### 12.6 Statutory Compliance

- **PF (EPF):**
  - Monthly ECR (Electronic Challan cum Return) generation
  - Employee + Employer contribution
  - PF report
- **ESI:**
  - Monthly ESI report
  - Half-yearly ESI return data
  - ESI challan
- **Professional Tax (PT):**
  - State-wise PT slab
  - Monthly PT deduction
  - PT challan
- **TDS on Salary (Form 24Q):**
  - Form 16 generation
  - Quarterly TDS return data

---

## 13. Phase 10 — Windows Integration & File System

### 13.1 Windows Native Integration

- Application icon (.ico)
- Desktop shortcut (auto-create on install)
- Taskbar icon
- System Tray icon:
  - Right-click menu: Open / New Bill / Backup / Exit
  - Minimize to tray on close
  - Show notification from tray
- Windows Start Menu integration
- App launch on Windows startup (optional setting)
- Windows Notification API (toast notifications)
- Windows File Association (open .erp backup files)
- Native file picker (Windows Explorer dialog)
- Native folder picker
- Native printer dialog
- Native color picker (for design)
- Multi-monitor support (drag window across screens)
- DPI-aware (sharp on 4K / high-DPI screens)
- Windows dark mode detection (auto-switch theme)
- Windows 10 / Windows 11 compatible
- Windows 7 / 8 fallback (if needed)

### 13.2 Keyboard Shortcuts (Complete)

| Action | Shortcut |
|---|---|
| New Bill | Ctrl+N |
| Save Bill | Ctrl+S |
| Print | Ctrl+P |
| PDF Export | Ctrl+Shift+P |
| Open Customer | Ctrl+K |
| Quick Search | Ctrl+F |
| Calculator | Ctrl+M |
| Today's Report | Ctrl+R |
| Backup Now | Ctrl+Shift+B |
| Settings | Ctrl+, |
| Lock App | Ctrl+L |
| Go to Dashboard | Ctrl+Home |
| WhatsApp Bill | Ctrl+W |
| Email Bill | Ctrl+E |
| Undo | Ctrl+Z |
| Redo | Ctrl+Y |
| Copy | Ctrl+C |
| Paste | Ctrl+V |
| Delete | Del |
| Escape / Cancel | Esc |
| F1 | Help |
| F2 | Edit |
| F5 | Refresh |
| F11 | Fullscreen toggle |
| F12 | Open Debug (dev only) |

### 13.3 File System & Folder Manager

```
[Windows User Documents]\CyberCafeERP\
│
├── Invoices\
│   ├── 2024-25\
│   │   ├── April\
│   │   │   ├── INV-001.pdf
│   │   │   ├── INV-001.json
│   │   │   └── ...
│   │   ├── May\
│   │   └── ...
│   └── 2025-26\
│
├── Customers\
│   ├── CustomerList.xlsx (auto-exported monthly)
│   └── Photos\
│
├── Products\
│   └── ProductImages\
│
├── Reports\
│   ├── Daily\
│   ├── Monthly\
│   └── Yearly\
│
├── Backup\
│   ├── Daily\
│   │   ├── 2026-07-19_backup.zip
│   │   └── ...
│   ├── Weekly\
│   └── Monthly\
│
├── GST\
│   ├── GSTR1\
│   ├── GSTR3B\
│   └── Eway_Bills\
│
├── Payroll\
│   ├── SalarySlips\
│   └── PF_ESI\
│
├── Assets\
│   ├── Logo\
│   ├── Signature\
│   └── Stamp\
│
├── Templates\
│   ├── InvoiceTemplates\
│   └── ReportTemplates\
│
├── Database\
│   ├── local.db (SQLite)
│   └── sync_queue.json
│
├── Logs\
│   ├── app.log
│   ├── audit.log
│   └── error.log
│
└── Settings\
    ├── config.json
    ├── templates.json
    └── shortcuts.json
```

### 13.4 Built-in File Manager Screen

- View all above folders in-app
- Open any file with double-click
- Rename / Delete / Copy / Move files
- Search files by name / date
- File preview (PDF, images inline)
- Send file by WhatsApp / Email from file manager
- File properties (size, created date, modified)
- Recycle Bin (deleted files recoverable for 30 days)

### 13.5 Drag & Drop Support

- Drag PDF onto invoice: attach to bill
- Drag image onto invoice: add image attachment
- Drag customer data Excel: import customers
- Drag product Excel: import products
- Drag backup ZIP: restore from it

---

## 14. Phase 11 — Multi-Company & Multi-Branch

### 14.1 Multi-Company (Tally Feature)

- Create multiple company profiles
- Each company has own:
  - Database (separate SQLite + MongoDB)
  - Settings
  - Financial years
  - Invoices (separate numbering)
  - Reports
  - Users
- Switch company from header (dropdown)
- Company password (separate from app password)
- Copy masters from one company to another (ledgers, products, customers)
- Consolidation report (all companies combined)
- Inter-company transactions
- Company list management

### 14.2 Multi-Branch

- Single company, multiple branches
- Branches share: customer master, product master, accounts
- Branch-wise inventory (separate stock)
- Branch-wise sales report
- Branch-wise billing
- Head office view (consolidated)
- Branch manager login (restricted to own branch)
- Inter-branch stock transfer
- Inter-branch billing

### 14.3 Multi-User System

| Role | Permissions |
|---|---|
| **Super Admin** | All access, delete, settings, user management |
| **Owner** | All access except user management |
| **Manager** | Billing, reports, inventory, customer; no settings |
| **Accountant** | Accounting, vouchers, reports; no billing settings |
| **Cashier** | Billing only; limited reports |
| **Operator** | View only; print; limited |
| **Custom Role** | Define permission for every screen/action |

**Permission Matrix (per role):**
- View / Create / Edit / Delete / Print / Export / Approve per module

**User Management:**
- Add / edit / remove users
- Assign role
- Username + Password + PIN
- User photo
- Active / Inactive
- User-specific sessions
- Login history (IP, device, time, duration)
- Activity log (every action logged with user ID)

---

## 15. Phase 12 — Security, Backup & Sync

### 15.1 Security

- **Application Lock:**
  - 4-digit or 6-digit PIN
  - Password (alphanumeric)
  - Auto-lock after N minutes inactivity
  - Lock on minimize (optional)
  - Lock on screensaver
- **Database Encryption:**
  - SQLite encrypted with AES-256
  - Sensitive data fields encrypted individually (passwords, PAN, Aadhaar)
- **Backup Encryption:**
  - ZIP backup encrypted with AES-256 + password
  - Password required to restore
- **Audit Trail (Tally-Feature):**
  - Every create, edit, delete logged
  - User who did it
  - Timestamp
  - Before/after values for edits
  - Audit log is read-only (cannot delete)
  - Audit report (filter by user, date, action)
- **Delete Protection:**
  - Posted vouchers cannot be deleted without admin override
  - Soft delete (move to recycle bin)
  - Permanent delete only by Super Admin
  - Confirmation dialog always
- **Voucher Lock:**
  - Lock period (e.g., lock all entries before March 31)
  - Locked entries cannot be edited/deleted
  - Unlock only by Super Admin with reason
- **User Permissions per Screen** (as above)
- **Failed Login Lockout:** 5 wrong attempts → lock for 30 minutes
- **Recovery Code:** Generate 24-character recovery code on setup (print it and store safely)

### 15.2 Backup System (Complete)

#### Manual Backup
- "Backup Now" button
- User chooses folder or use default
- Creates timestamped ZIP file
- Progress bar with estimated size
- Success notification

#### Automatic Backup
- Daily backup (choose time — default: 11 PM)
- Weekly backup (choose day)
- Monthly backup (1st of month)
- Yearly backup (March 31)
- Auto-backup runs in background even if app is open
- Skip if no changes since last backup
- Max backup count (auto-delete oldest)

#### Backup Contents
- SQLite database
- All PDFs (invoices, reports)
- Product images
- Business logo, signature, stamp
- Invoice templates
- Application settings / config
- Audit logs

#### Backup Verification
- After each backup, auto-verify ZIP integrity
- Show backup size + file count
- Show last backup time on dashboard
- Alert if last backup > 24 hours

#### Cloud Backup (Optional)
- Google Drive (OAuth2 login)
- Dropbox
- FTP / SFTP server
- OneDrive
- Auto-upload after local backup
- Cloud backup history
- Restore from cloud

#### Restore Process
- Select backup ZIP file
- Enter backup password
- Preview backup info (date, size, data count)
- Confirm restore
- Progress bar
- App restart after restore
- Current data backed up before restore

### 15.3 MongoDB Sync

- **Offline-first:** all operations on SQLite
- **Background sync queue:** every change adds to queue
- **Sync when online:** auto-sync every 5 minutes when internet available
- **Manual sync:** "Sync Now" button
- **Conflict resolution:**
  - Last-write-wins (default)
  - Manual conflict resolution UI (show both versions, user picks)
- **Sync status indicator:** (synced / pending / error) in header
- **Sync log:** view all sync activity
- **Selective sync:** choose which data to sync (customers / invoices / products / accounts)
- **Multi-device:** same MongoDB data accessible from multiple Windows PCs (different branches)

---

## 16. Phase 13 — Printing System

### 16.1 Thermal Printer (ESC/POS)

- 58mm and 80mm paper width support
- ESC/POS commands via Win32 / dart_serial
- Auto-detect thermal printer from Windows printer list
- Thermal invoice template (compact layout)
- Center-aligned shop name
- Dashed line dividers
- Right-aligned total
- QR code for UPI payment (small size)
- "Thank you" footer message
- Cut command after print
- Open cash drawer command (if connected)
- Re-print last bill (one click from dashboard)

### 16.2 A4 / A5 / Letter / Legal Printer

- Full CorelDRAW-designed templates
- Windows printer dialog
- Portrait and landscape support
- Multi-page invoices (auto-continue on next page)
- Print multiple copies (Original / Duplicate / Triplicate)
- Watermark per copy
- Page numbers (Page X of Y)
- Header on each page (company name)
- Footer on each page (Terms & Conditions, page number)
- Print preview (full page view before printing)
- Zoom in print preview

### 16.3 Label Printer

- Custom label size
- Customer name + phone label
- Product barcode label
- Price tag label
- Address label (for courier)
- Zebra / Dymo label printer support

### 16.4 PDF Export

- Save as PDF (any template)
- PDF password protection (optional)
- PDF metadata (company name, invoice number)
- Compressed PDF option
- Merge multiple invoices into one PDF
- Batch PDF export (all invoices of a period)

### 16.5 Print Queue

- Print multiple bills at once
- Print queue status (printing / pending / done / error)
- Cancel print job
- Reprint from queue

### 16.6 Email Invoice

- SMTP settings (Gmail / Outlook / custom)
- Email template (HTML)
- Attach PDF automatically
- CC / BCC option
- Bulk email (monthly statements)
- Email delivery status

### 16.7 WhatsApp Invoice

- WhatsApp URL scheme (wa.me)
- PDF attached + pre-filled message
- Business WhatsApp API (optional — paid)
- WhatsApp number from customer profile
- One-click from bill screen

### 16.8 SMS (Optional)

- SMS gateway integration (Fast2SMS / TextLocal / MSG91)
- SMS template (bill amount, payment link)
- SMS balance check
- Bulk SMS (payment reminders)
- SMS log

---

## 17. Phase 14 — Advanced & Extra Features

### 17.1 Built-in Calculator

- Full scientific calculator
- Accessible by Ctrl+M from anywhere
- History of calculations
- Copy result to clipboard
- GST calculator mode (enter amount + rate → CGST/SGST split)
- EMI calculator
- Interest calculator
- Profit margin calculator

### 17.2 Calendar & Reminders

- Built-in monthly calendar view
- Mark important dates:
  - GST return due dates (auto-marked)
  - TDS payment dates (auto-marked)
  - Customer payment due dates
  - Bill due dates
  - Custom reminders
- Click date to see all events
- Set reminder notification for any event

### 17.3 Notes System

- Quick Notes (floating sticky note from tray)
- Rich text notes (bold, color, bullet)
- Pin important notes to dashboard
- Note categories
- Search notes
- Share note as PDF
- To-do checklist inside notes
- Note reminder (alert at a set time)

### 17.4 Voice Search

- Press microphone button or say "Hey ERP" (optional always-on)
- Search by voice:
  - "Find customer Ramesh"
  - "Show today's sales"
  - "Create new bill"
  - "Stock of A4 paper"
- Windows speech recognition API
- Hindi + English (Hinglish) support

### 17.5 QR Scanner (for billing)

- USB barcode scanner support (keyboard emulation)
- Webcam barcode scanner (using ZXing / camera_windows plugin)
- Scan product barcode → auto-fill item in bill
- Scan customer QR code → auto-select customer
- Scan document QR code → open linked document

### 17.6 Expense Tracker

- Quick expense entry (cash / bank)
- Expense categories: Rent / Electricity / Internet / Salary / Stationery / Repair / Fuel / etc.
- Recurring expenses (monthly rent auto-entry)
- Expense with GST (ITC claimable)
- Bill attachment (photo of expense bill)
- Petty cash management
- Expense report (category-wise, date-wise)

### 17.7 Vehicle & Fuel Expense

- Vehicle master (bike / car / van)
- Fuel log (date, qty, rate, odometer)
- Fuel expense auto-categorize
- Mileage calculation
- Vehicle maintenance log
- Vehicle expense report

### 17.8 Cheque Management

- Cheque received (from customer)
- Cheque issued (to supplier)
- Cheque status: Received / Deposited / Cleared / Bounced / Cancelled
- Cheque book register
- Upcoming cheque clearance alerts
- Bounced cheque handling
- Cheque register report

### 17.9 Document Attachment

- Attach any document to any voucher / customer / supplier / product
- Supported types: PDF, JPG, PNG, Excel, Word
- Max 10 files per record
- File preview inside app
- Document storage in Windows folder
- Document search

### 17.10 Recycle Bin & Undo

- All deleted records go to recycle bin
- Recycle bin retention: 90 days
- Restore from recycle bin
- Permanent delete from recycle bin
- Audit log of deletions
- Ctrl+Z undo for last action

### 17.11 OCR Bill Scanner (Optional Advanced)

- Scan paper bill using webcam / scanner
- OCR extracts: Vendor name, amount, date, GST number
- Auto-create expense entry from scan
- Powered by Windows OCR API / Tesseract
- Manual correction before saving

### 17.12 UPI QR Generation

- Generate UPI payment QR for any amount
- UPI ID from settings
- QR shows on invoice
- QR show on payment screen (customer scans and pays)
- Verify payment received (optional: UPI API)
- Dynamic QR (amount pre-filled)

### 17.13 Customer Portal (Future Phase — Web)

- Customer login to see their bills
- Download invoices
- Outstanding balance
- Payment history
- Make payment online (Razorpay / PhonePe)
- Share portal link via WhatsApp

### 17.14 Multi-Theme System

- 12 built-in color themes
- Custom theme creator (choose 3 colors)
- Dark + Light variant per theme
- Theme preview live
- Import / Export themes
- Seasonal themes (Diwali, Holi, New Year)

### 17.15 License & Subscription System

- License key activation
- Trial mode (30 days, limited bills)
- Offline license validation
- Online license renewal
- License transfer to new PC
- License report

### 17.16 Software Auto-Update

- Check for updates on startup
- Manual update check
- Download update in background
- Changelog display
- Install on next restart
- Version history
- Rollback to previous version

### 17.17 Help & Tutorial System

- Built-in help documentation
- Video tutorial links
- Tooltip on every field
- First-time walkthrough wizard (per screen)
- FAQ section
- Contact support button (WhatsApp / Email / Phone)
- Remote support (generate session code for tech support)

### 17.18 Data Recovery

- Corrupt database detection on startup
- Auto-recovery from last backup
- Manual recovery mode
- Export partial data even from damaged database
- Support contact for data recovery

### 17.19 Business Analytics (Advanced Dashboard)

- Hourly sales heatmap (which hours are busiest)
- Day-wise trend (which days have most sales)
- Seasonal analysis (Diwali vs normal month)
- Customer segmentation (new vs returning)
- Product velocity (how fast products sell)
- Profitability heatmap
- Expense vs income trend
- Break-even calculator

---

## 18. Database Schema Overview

### Core Collections (MongoDB) / Tables (SQLite)

```
companies           → Multi-company support
├── users           → Login users per company
├── settings        → All app settings
└── audit_log       → Every action logged

accounts
├── account_groups  → COA groups (Tally-compatible)
├── ledgers         → All ledger accounts
└── opening_bal     → Opening balances

vouchers
├── voucher_header  → Main voucher (date, type, number)
├── voucher_entries → Double-entry lines (Dr/Cr)
├── voucher_bills   → Bill-by-bill references
└── voucher_docs    → Attached documents

billing
├── bills           → Invoice header
├── bill_items      → Invoice line items
├── bill_tax        → GST breakup per bill
├── bill_payments   → Multi-mode payments
└── bill_copies     → Original/Duplicate tracking

customers
├── customer_master → Customer details
├── customer_docs   → Documents
├── loyalty_points  → Points ledger
└── customer_tags   → Tags

suppliers
├── supplier_master → Supplier details
└── supplier_docs   → Documents

inventory
├── items           → Products/services
├── item_images     → Product images
├── stock_entries   → Stock movement
├── batches         → Batch tracking
├── locations       → Godown/locations
└── price_lists     → Multiple price lists

payroll
├── employees       → Employee master
├── salary_struct   → Salary structures
├── attendance      → Daily attendance
├── leaves          → Leave records
├── salary_runs     → Monthly payroll
└── salary_lines    → Salary components per run

gst_compliance
├── einvoice        → IRN records
├── ewaybill        → EWB records
├── gstr1_data      → GSTR-1 generated data
└── gstr3b_data     → GSTR-3B generated data

misc
├── notes           → User notes
├── reminders       → Calendar reminders
├── cheques         → Cheque register
├── expenses        → Quick expenses
├── vehicles        → Vehicle log
└── templates       → Invoice templates (JSON)
```

---

## 19. Folder Structure

```
CyberCafeERP/
│
├── flutter_windows/                    # Flutter Windows app
│   ├── lib/
│   │   ├── main.dart
│   │   ├── app/
│   │   │   ├── app.dart               # App entry + theme
│   │   │   ├── router.dart            # GoRouter config
│   │   │   └── constants.dart
│   │   ├── core/
│   │   │   ├── database/
│   │   │   │   ├── sqlite_db.dart
│   │   │   │   ├── mongodb_sync.dart
│   │   │   │   └── sync_queue.dart
│   │   │   ├── printing/
│   │   │   │   ├── thermal_printer.dart
│   │   │   │   ├── a4_printer.dart
│   │   │   │   └── pdf_generator.dart
│   │   │   ├── backup/
│   │   │   │   ├── backup_manager.dart
│   │   │   │   └── restore_manager.dart
│   │   │   ├── security/
│   │   │   │   ├── auth_manager.dart
│   │   │   │   └── encryption.dart
│   │   │   ├── windows/
│   │   │   │   ├── tray_icon.dart
│   │   │   │   └── windows_api.dart
│   │   │   └── utils/
│   │   │       ├── indian_number.dart
│   │   │       ├── gst_calculator.dart
│   │   │       └── amount_in_words.dart
│   │   ├── features/
│   │   │   ├── auth/                  # Login, PIN, lock
│   │   │   ├── dashboard/             # Home screen
│   │   │   ├── billing/               # Invoice creation
│   │   │   ├── customers/             # Customer CRM
│   │   │   ├── suppliers/             # Supplier module
│   │   │   ├── inventory/             # Stock management
│   │   │   ├── accounting/            # Vouchers, ledgers
│   │   │   ├── reports/               # All reports
│   │   │   ├── gst/                   # GST returns
│   │   │   ├── payroll/               # HR & salary
│   │   │   ├── invoice_designer/      # CorelDRAW-style
│   │   │   ├── backup/                # Backup & restore
│   │   │   ├── settings/              # All settings
│   │   │   ├── file_manager/          # File browser
│   │   │   ├── calculator/            # Built-in calc
│   │   │   ├── notes/                 # Notes system
│   │   │   └── help/                  # Help & tutorials
│   │   └── shared/
│   │       ├── widgets/               # Reusable UI components
│   │       ├── providers/             # Riverpod providers
│   │       ├── models/                # Data models
│   │       └── theme/                 # Colors, fonts
│   ├── windows/                       # Windows runner
│   ├── assets/                        # Images, icons, fonts
│   └── pubspec.yaml
│
├── backend/                           # Node.js + Express
│   ├── src/
│   │   ├── app.js
│   │   ├── config/
│   │   │   ├── database.js            # MongoDB connection
│   │   │   └── constants.js
│   │   ├── routes/
│   │   │   ├── auth.routes.js
│   │   │   ├── billing.routes.js
│   │   │   ├── customer.routes.js
│   │   │   ├── inventory.routes.js
│   │   │   ├── accounting.routes.js
│   │   │   ├── reports.routes.js
│   │   │   ├── gst.routes.js
│   │   │   ├── backup.routes.js
│   │   │   └── sync.routes.js
│   │   ├── controllers/               # Business logic
│   │   ├── models/                    # Mongoose schemas
│   │   ├── middleware/                # Auth, validation
│   │   ├── services/
│   │   │   ├── gst.service.js         # GST calculation
│   │   │   ├── email.service.js
│   │   │   ├── backup.service.js
│   │   │   └── sync.service.js
│   │   └── utils/
│   │       ├── indian_format.js
│   │       └── pdf_generator.js
│   ├── package.json
│   └── .env
│
├── installer/                         # NSIS / Inno Setup
│   ├── setup.iss
│   ├── installer_assets/
│   │   ├── app_icon.ico
│   │   └── setup_banner.bmp
│   └── README.md
│
├── database/
│   ├── schema/
│   │   ├── sqlite_schema.sql
│   │   └── mongodb_indexes.js
│   └── migrations/
│
└── docs/
    ├── PRD.md (this file)
    ├── API.md
    ├── INSTALL.md
    └── USER_MANUAL.md
```

---

## 20. Final Deliverables

### App Deliverables

- [ ] `CyberCafeERP_Setup.exe` — Windows installer
- [ ] `CyberCafeERP_Portable.zip` — Portable version (no install needed)
- [ ] Backend deployed on Render.com (for cloud sync)
- [ ] MongoDB Atlas database configured

### Installer Features (NSIS / Inno Setup)

- Branded installer with logo
- Custom install path
- Desktop shortcut creation
- Start menu entry
- Uninstaller with data option (keep/delete data)
- License agreement screen
- Auto-detect .NET / VC++ redistributables
- Silent install mode (for bulk deployment)

### Documentation

- [ ] User Manual PDF (Hindi + English)
- [ ] Quick Start Guide (1 page — print-ready)
- [ ] Video tutorials playlist (link)
- [ ] API documentation (for developers)
- [ ] Database schema documentation

### Support System

- WhatsApp support number
- Email support
- Remote desktop session support (AnyDesk / TeamViewer)
- YouTube tutorial channel

---

## Summary — Feature Count

| Module | Total Features |
|---|---|
| Dashboard & Settings | 80+ |
| GST Billing System | 120+ |
| Tally Accounting Engine | 150+ |
| CorelDRAW Invoice Designer | 80+ |
| Inventory & Supplier | 90+ |
| Customer CRM | 60+ |
| GST Compliance & Returns | 70+ |
| Reports Engine | 100+ |
| Payroll & HR | 70+ |
| Windows Integration | 50+ |
| Multi-Company & Users | 40+ |
| Security & Backup | 60+ |
| Printing System | 50+ |
| Extra Features | 80+ |
| **TOTAL** | **~1,100+ Features** |

---

> **Built with ❤️ for Uncle's Cyber Café — Simple enough for a non-technical owner, Powerful enough to replace Tally + CorelDRAW both.**

---

*PRD Version: 2.0 | Created by: Zenus | Target: CyberCafe Uncle | Platform: Flutter Desktop Windows*
