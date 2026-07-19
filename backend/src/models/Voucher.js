import mongoose from 'mongoose';

const voucherEntrySchema = new mongoose.Schema(
  {
    ledger: { type: String, required: true },
    debit: { type: Number, default: 0 },
    credit: { type: Number, default: 0 },
    narration: { type: String, default: '' },
  },
  { _id: false }
);

const voucherSchema = new mongoose.Schema(
  {
    voucherType: {
      type: String,
      enum: ['Receipt', 'Payment', 'Journal', 'Sales', 'Purchase',
        'Credit Note', 'Debit Note', 'Contra'],
      required: true,
    },
    voucherNumber: { type: String, required: true, unique: true, index: true },
    date: { type: Date, default: Date.now, index: true },
    entries: [voucherEntrySchema],
    narration: { type: String, default: '' },
    amount: { type: Number, default: 0 },
    createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  },
  { timestamps: true }
);

export default mongoose.model('Voucher', voucherSchema);
