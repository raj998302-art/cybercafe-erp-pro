const ones = ['', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight',
  'Nine', 'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen',
  'Seventeen', 'Eighteen', 'Nineteen'];
const tens = ['', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy',
  'Eighty', 'Ninety'];
const scales = ['', 'Thousand', 'Lakh', 'Crore'];

function twoOrThreeDigit(n) {
  if (n === 0) return '';
  if (n < 20) return ones[n];
  if (n < 100) return `${tens[Math.floor(n / 10)]}${n % 10 !== 0 ? ' ' + ones[n % 10] : ''}`;
  const h = Math.floor(n / 100);
  const rem = n % 100;
  let s = `${ones[h]} Hundred`;
  if (rem > 0) s += ' ' + twoOrThreeDigit(rem);
  return s;
}

function convertIndian(n) {
  if (n === 0) return '';
  const parts = [];
  const thousands = n % 1000;
  n = Math.floor(n / 1000);
  parts.unshift(twoOrThreeDigit(thousands));
  let scaleIdx = 1;
  while (n > 0) {
    const grp = n % 100;
    n = Math.floor(n / 100);
    if (grp > 0) parts.unshift(`${twoOrThreeDigit(grp)} ${scales[scaleIdx]}`);
    scaleIdx++;
  }
  return parts.filter(Boolean).join(' ').trim();
}

export function numberToIndianWords(amount) {
  if (!amount) return 'Zero Rupees Only';
  const rupees = Math.trunc(amount);
  const paise = Math.round((amount - rupees) * 100);
  let words = '';
  if (rupees > 0) words = `${convertIndian(rupees)} Rupees`;
  if (paise > 0) {
    if (rupees > 0) words += ' and ';
    words += `${convertIndian(paise)} Paise`;
  }
  return `${words} Only`;
}

export function formatINR(amount) {
  const n = Number(amount || 0);
  return new Intl.NumberFormat('en-IN', {
    style: 'currency',
    currency: 'INR',
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  }).format(n);
}
