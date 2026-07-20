import mongoose from 'mongoose';

const itemSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    shortName: { type: String, default: '', uppercase: true, trim: true },
    category: { type: String, default: 'Custom' },
    unit: { type: String, default: 'Flat' },
    price: { type: Number, default: 0 },
    gstRate: { type: Number, default: 0 },
    hsnCode: { type: String, default: '' },
    sacCode: { type: String, default: '' },
    stockQty: { type: Number, default: 0 },
    minStock: { type: Number, default: 0 },
    isService: { type: Boolean, default: true },
    active: { type: Boolean, default: true },
    sortOrder: { type: Number, default: 0 },
    createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  },
  { timestamps: true }
);

itemSchema.index({ name: 'text', shortName: 'text' });

export default mongoose.model('Item', itemSchema);
