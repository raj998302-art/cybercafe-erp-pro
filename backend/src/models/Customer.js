import mongoose from 'mongoose';

const customerSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    phone: { type: String, default: '', trim: true, index: true },
    email: { type: String, default: '', trim: true, lowercase: true },
    gstin: { type: String, default: '', uppercase: true, trim: true },
    address: { type: String, default: '' },
    state: { type: String, default: '' },
    openingBalance: { type: Number, default: 0 },
    balanceType: { type: String, enum: ['debit', 'credit'], default: 'debit' },
    tags: [{ type: String }],
    notes: { type: String, default: '' },
    createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  },
  { timestamps: true }
);

customerSchema.index({ name: 'text', phone: 'text' });

export default mongoose.model('Customer', customerSchema);
