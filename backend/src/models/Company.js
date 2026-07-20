import mongoose from 'mongoose';

const companySchema = new mongoose.Schema(
  {
    name: { type: String, required: true, default: 'My Cyber Cafe' },
    gstin: { type: String, default: '' },
    pan: { type: String, default: '' },
    address: {
      line1: String,
      line2: String,
      city: String,
      state: String,
      pincode: String,
    },
    phone: { type: String, default: '' },
    email: { type: String, default: '' },
    logo: { type: String, default: '' },
    bankDetails: {
      bankName: String,
      accountName: String,
      accountNumber: String,
      ifsc: String,
      branch: String,
    },
    termsConditions: { type: String, default: '' },
    signature: { type: String, default: '' },
    invoicePrefix: { type: String, default: 'INV' },
    invoiceCounter: { type: Number, default: 0 },
  },
  { timestamps: true }
);

export default mongoose.model('Company', companySchema);
