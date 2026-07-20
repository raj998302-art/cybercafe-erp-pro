import mongoose from 'mongoose';

const ledgerSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true, index: true },
    group: { type: String, default: 'Miscellaneous' },
    openingBalance: { type: Number, default: 0 },
    balanceType: { type: String, enum: ['debit', 'credit'], default: 'debit' },
    gstin: { type: String, default: '' },
    phone: { type: String, default: '' },
    address: { type: String, default: '' },
    linkedCustomer: { type: mongoose.Schema.Types.ObjectId, ref: 'Customer' },
    linkedSupplier: { type: mongoose.Schema.Types.ObjectId, ref: 'Supplier' },
  },
  { timestamps: true }
);

export default mongoose.model('Ledger', ledgerSchema);
