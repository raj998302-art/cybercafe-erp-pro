import mongoose from 'mongoose';

const billItemSchema = new mongoose.Schema(
  {
    itemId: { type: mongoose.Schema.Types.ObjectId, ref: 'Item' },
    name: { type: String, required: true },
    qty: { type: Number, default: 1 },
    rate: { type: Number, default: 0 },
    discount: { type: Number, default: 0 },
    gstRate: { type: Number, default: 0 },
    gstAmount: { type: Number, default: 0 },
    total: { type: Number, default: 0 },
  },
  { _id: false }
);

const billSchema = new mongoose.Schema(
  {
    billNumber: { type: String, required: true, unique: true, index: true },
    billDate: { type: Date, default: Date.now, index: true },
    customer: { type: mongoose.Schema.Types.ObjectId, ref: 'Customer' },
    customerSnapshot: {
      name: String,
      phone: String,
      gstin: String,
      address: String,
      state: String,
    },
    items: [billItemSchema],
    subtotal: { type: Number, default: 0 },
    totalDiscount: { type: Number, default: 0 },
    totalGst: { type: Number, default: 0 },
    cgst: { type: Number, default: 0 },
    sgst: { type: Number, default: 0 },
    igst: { type: Number, default: 0 },
    roundOff: { type: Number, default: 0 },
    grandTotal: { type: Number, default: 0 },
    paymentMode: { type: String, default: 'Cash' },
    paymentStatus: {
      type: String,
      enum: ['paid', 'partial', 'unpaid'],
      default: 'unpaid',
    },
    paidAmount: { type: Number, default: 0 },
    balanceDue: { type: Number, default: 0 },
    notes: { type: String, default: '' },
    termsConditions: { type: String, default: '' },
    templateName: { type: String, default: 'default' },
    company: { type: mongoose.Schema.Types.ObjectId, ref: 'Company' },
    createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  },
  { timestamps: true }
);

export default mongoose.model('Bill', billSchema);
