/**
 * GST calculation utilities.
 * Intra-state → CGST + SGST (half each)
 * Inter-state → IGST (full)
 */
export function calculateGST(taxable, gstRate, isIntraState = true) {
  const gst = (Number(taxable) * Number(gstRate)) / 100;
  if (isIntraState) {
    const half = round(gst / 2);
    return { cgst: half, sgst: half, igst: 0, total: round(gst) };
  }
  return { cgst: 0, sgst: 0, igst: round(gst), total: round(gst) };
}

function round(v) {
  return Math.round((Number(v) + Number.EPSILON) * 100) / 100;
}

export function isStateSame(companyState, customerState) {
  if (!companyState || !customerState) return true; // default intra-state
  return companyState.trim().toLowerCase() === customerState.trim().toLowerCase();
}

/**
 * Build GSTR-1 summary from a list of bills.
 * Returns b2b, b2c, hsn summary.
 */
export function formatGSTR1(bills = []) {
  const b2b = [];
  const b2c = [];
  const hsnMap = new Map();

  for (const b of bills) {
    const taxable = (b.subtotal || 0) - (b.totalDiscount || 0);
    const totalGst = b.totalGst || 0;
    const entry = {
      billNumber: b.billNumber,
      date: b.billDate,
      customerName: b.customerSnapshot?.name || '',
      customerGstin: b.customerSnapshot?.gstin || '',
      taxableValue: round(taxable),
      igst: round(b.igst || 0),
      cgst: round(b.cgst || 0),
      sgst: round(b.sgst || 0),
      total: round(b.grandTotal || 0),
    };
    if (entry.customerGstin) b2b.push(entry);
    else b2c.push(entry);

    for (const it of b.items || []) {
      const lineTaxable = round((it.qty * it.rate) - (it.discount || 0));
      const lineGst = round(it.gstAmount || 0);
      const key = `${it.hsnCode || 'NA'}-${it.gstRate}`;
      const prev = hsnMap.get(key) || { hsn: it.hsnCode || 'NA', gstRate: it.gstRate, taxable: 0, gst: 0 };
      prev.taxable = round(prev.taxable + lineTaxable);
      prev.gst = round(prev.gst + lineGst);
      hsnMap.set(key, prev);
    }
  }

  return {
    summary: {
      totalB2bBills: b2b.length,
      totalB2cBills: b2c.length,
      totalTaxable: round(bills.reduce((s, b) => s + (b.subtotal || 0) - (b.totalDiscount || 0), 0)),
      totalGst: round(bills.reduce((s, b) => s + (b.totalGst || 0), 0)),
      totalInvoiceValue: round(bills.reduce((s, b) => s + (b.grandTotal || 0), 0)),
    },
    b2b,
    b2c,
    hsnSummary: Array.from(hsnMap.values()),
  };
}

export function formatGSTR3B(bills = [], expenses = []) {
  const gstr1 = formatGSTR1(bills);
  const inputTax = expenses.reduce((s, e) => s + (e.gstAmount || 0), 0);
  return {
    outwardSupplies: gstr1.summary,
    inputTaxCredit: round(inputTax),
    netTaxPayable: round(gstr1.summary.totalGst - inputTax),
  };
}
