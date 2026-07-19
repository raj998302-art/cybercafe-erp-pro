import mongoose from 'mongoose';

const supplierSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    phone: { type: String, default: '' },
    email: { type: String, default: '' },
    gstin: { type: String, default: '' },
    address: { type: String, default: '' },
    state: { type: String, default: '' },
    openingBalance: { type: Number, default: 0 },
    balanceType: { type: String, enum: ['debit', 'credit'], default: 'credit' },
    notes: { type: String, default: '' },
  },
  { timestamps: true }
);

export default mongoose.model('Supplier', supplierSchema);
