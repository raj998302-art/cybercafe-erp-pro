export const GST_RATES = [0, 0.25, 3, 5, 12, 18, 28];

export const VOUCHER_TYPES = [
  'Receipt', 'Payment', 'Journal', 'Sales', 'Purchase',
  'Credit Note', 'Debit Note', 'Contra',
];

export const PAYMENT_MODES = [
  'Cash', 'UPI', 'Card', 'Net Banking', 'Cheque', 'Wallet', 'Credit',
];

export const ITEM_CATEGORIES = [
  'Print', 'Xerox', 'Cyber', 'Govt Service', 'Stationery', 'Custom',
];

export const UNITS = [
  'Per Page', 'Per Hour', 'Per Set', 'Per Form', 'Per Piece',
  'Per Card', 'Per Book', 'Per Txn', 'Flat', 'Custom',
];

export const BILL_STATUS = ['paid', 'partial', 'unpaid'];

// Default cyber cafe items (42 items) — pre-loaded on first seed.
export const DEFAULT_ITEMS = [
  { name: 'Color Print A4', shortName: 'CLR A4', category: 'Print', unit: 'Per Page', price: 10, gstRate: 18, hsnCode: '9989' },
  { name: 'B&W Print A4', shortName: 'BW A4', category: 'Print', unit: 'Per Page', price: 2, gstRate: 18, hsnCode: '9989' },
  { name: 'Color Print A3', shortName: 'CLR A3', category: 'Print', unit: 'Per Page', price: 20, gstRate: 18, hsnCode: '9989' },
  { name: 'B&W Print A3', shortName: 'BW A3', category: 'Print', unit: 'Per Page', price: 5, gstRate: 18, hsnCode: '9989' },
  { name: 'Xerox / Photocopy A4', shortName: 'XROX', category: 'Xerox', unit: 'Per Page', price: 1, gstRate: 18, hsnCode: '9989' },
  { name: 'Xerox Color A4', shortName: 'XCLR', category: 'Xerox', unit: 'Per Page', price: 8, gstRate: 18, hsnCode: '9989' },
  { name: 'Lamination A4', shortName: 'LAM A4', category: 'Custom', unit: 'Per Piece', price: 15, gstRate: 18, hsnCode: '9989' },
  { name: 'Lamination A3', shortName: 'LAM A3', category: 'Custom', unit: 'Per Piece', price: 25, gstRate: 18, hsnCode: '9989' },
  { name: 'Spiral Binding', shortName: 'SPBND', category: 'Custom', unit: 'Per Book', price: 30, gstRate: 18, hsnCode: '9989' },
  { name: 'Hard Binding', shortName: 'HDBND', category: 'Custom', unit: 'Per Book', price: 80, gstRate: 18, hsnCode: '9989' },
  { name: 'Passport Photo (set of 4)', shortName: 'PP4', category: 'Custom', unit: 'Per Set', price: 50, gstRate: 18, hsnCode: '9989' },
  { name: 'Passport Photo (set of 6)', shortName: 'PP6', category: 'Custom', unit: 'Per Set', price: 70, gstRate: 18, hsnCode: '9989' },
  { name: 'ID Card Making', shortName: 'IDCRD', category: 'Custom', unit: 'Per Card', price: 30, gstRate: 18, hsnCode: '9989' },
  { name: 'Scanning (per page)', shortName: 'SCAN', category: 'Custom', unit: 'Per Page', price: 5, gstRate: 18, hsnCode: '9989' },
  { name: 'Typing (per page)', shortName: 'TYPE', category: 'Custom', unit: 'Per Page', price: 15, gstRate: 18, hsnCode: '9989' },
  { name: 'Computer Rental', shortName: 'CMP', category: 'Cyber', unit: 'Per Hour', price: 30, gstRate: 18, hsnCode: '9986' },
  { name: 'Internet Browsing', shortName: 'NET', category: 'Cyber', unit: 'Per Hour', price: 20, gstRate: 18, hsnCode: '9986' },
  { name: 'Aadhaar New Enrollment', shortName: 'ADHR', category: 'Govt Service', unit: 'Flat', price: 50, gstRate: 0, hsnCode: '9992' },
  { name: 'Aadhaar Update / Correction', shortName: 'ADHU', category: 'Govt Service', unit: 'Flat', price: 50, gstRate: 0, hsnCode: '9992' },
  { name: 'PAN Card Apply', shortName: 'PAN', category: 'Govt Service', unit: 'Flat', price: 100, gstRate: 0, hsnCode: '9992' },
  { name: 'PAN Card Correction', shortName: 'PANC', category: 'Govt Service', unit: 'Flat', price: 100, gstRate: 0, hsnCode: '9992' },
  { name: 'Voter ID Apply', shortName: 'VOT', category: 'Govt Service', unit: 'Flat', price: 50, gstRate: 0, hsnCode: '9992' },
  { name: 'Income Certificate', shortName: 'INC', category: 'Govt Service', unit: 'Flat', price: 100, gstRate: 0, hsnCode: '9992' },
  { name: 'Caste Certificate', shortName: 'CST', category: 'Govt Service', unit: 'Flat', price: 100, gstRate: 0, hsnCode: '9992' },
  { name: 'Domicile Certificate', shortName: 'DOM', category: 'Govt Service', unit: 'Flat', price: 100, gstRate: 0, hsnCode: '9992' },
  { name: 'Birth Certificate', shortName: 'BTH', category: 'Govt Service', unit: 'Flat', price: 80, gstRate: 0, hsnCode: '9992' },
  { name: 'Death Certificate', shortName: 'DTH', category: 'Govt Service', unit: 'Flat', price: 80, gstRate: 0, hsnCode: '9992' },
  { name: 'Train Ticket (IRCTC)', shortName: 'TRN', category: 'Custom', unit: 'Per Txn', price: 30, gstRate: 5, hsnCode: '9964' },
  { name: 'Air Ticket', shortName: 'AIR', category: 'Custom', unit: 'Per Txn', price: 150, gstRate: 5, hsnCode: '9964' },
  { name: 'Bus Ticket', shortName: 'BUS', category: 'Custom', unit: 'Per Txn', price: 30, gstRate: 5, hsnCode: '9964' },
  { name: 'Passport Application', shortName: 'PSP', category: 'Govt Service', unit: 'Flat', price: 200, gstRate: 18, hsnCode: '9992' },
  { name: 'Visa Application', shortName: 'VISA', category: 'Govt Service', unit: 'Flat', price: 300, gstRate: 18, hsnCode: '9992' },
  { name: 'Mobile Recharge', shortName: 'MOB', category: 'Custom', unit: 'Per Txn', price: 10, gstRate: 0, hsnCode: '9989' },
  { name: 'DTH Recharge', shortName: 'DTH', category: 'Custom', unit: 'Per Txn', price: 10, gstRate: 0, hsnCode: '9989' },
  { name: 'Electricity Bill', shortName: 'ELEC', category: 'Custom', unit: 'Per Txn', price: 20, gstRate: 0, hsnCode: '9989' },
  { name: 'Gas Bill Payment', shortName: 'GAS', category: 'Custom', unit: 'Per Txn', price: 20, gstRate: 0, hsnCode: '9989' },
  { name: 'Water Bill Payment', shortName: 'WTR', category: 'Custom', unit: 'Per Txn', price: 20, gstRate: 0, hsnCode: '9989' },
  { name: 'GST Registration', shortName: 'GSTR', category: 'Govt Service', unit: 'Flat', price: 500, gstRate: 18, hsnCode: '9992' },
  { name: 'Income Tax Return', shortName: 'ITR', category: 'Govt Service', unit: 'Flat', price: 300, gstRate: 18, hsnCode: '9992' },
  { name: 'Courier / Speed Post', shortName: 'CRR', category: 'Custom', unit: 'Flat', price: 50, gstRate: 18, hsnCode: '9968' },
];
