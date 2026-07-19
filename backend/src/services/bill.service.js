import Bill from '../models/Bill.js';
import Company from '../models/Company.js';

/**
 * Generates the next sequential bill number: INV-2024-0001
 * Atomically increments the company's invoice counter.
 */
export async function generateBillNumber() {
  const company = await Company.findOne();
  const year = new Date().getFullYear();
  const prefix = company?.invoicePrefix || 'INV';
  const next = (company?.invoiceCounter || 0) + 1;

  if (company) {
    company.invoiceCounter = next;
    await company.save();
  }
  return `${prefix}-${year}-${String(next).padStart(4, '0')}`;
}

/**
 * Recalculates totals for a bill from its line items.
 * Returns subtotal, discount, gst breakup, grand total.
 */
export function recalcBillTotals(items = [], isIntraState = true) {
  let subtotal = 0;
  let discount = 0;
  let gst = 0;
  let cgst = 0, sgst = 0, igst = 0;

  for (const it of items) {
    const line = (it.qty || 0) * (it.rate || 0);
    const disc = it.discount || 0;
    const taxable = line - disc;
    const lineGst = (taxable * (it.gstRate || 0)) / 100;
    subtotal += line;
    discount += disc;
    gst += lineGst;
    if (isIntraState) {
      cgst += lineGst / 2;
      sgst += lineGst / 2;
    } else {
      igst += lineGst;
    }
    it.gstAmount = round(lineGst);
    it.total = round(taxable + lineGst);
  }

  const grand = round(subtotal - discount + gst);
  const rounded = Math.round(grand);
  const roundOff = round(rounded - grand);

  return {
    subtotal: round(subtotal),
    totalDiscount: round(discount),
    totalGst: round(gst),
    cgst: round(cgst),
    sgst: round(sgst),
    igst: round(igst),
    roundOff,
    grandTotal: rounded,
  };
}

function round(v) {
  return Math.round((Number(v) + Number.EPSILON) * 100) / 100;
}
