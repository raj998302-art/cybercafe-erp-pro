import mongoose from 'mongoose';

const expenseSchema = new mongoose.Schema(
  {
    date: { type: Date, default: Date.now, index: true },
    category: { type: String, default: 'General' },
    amount: { type: Number, default: 0 },
    paymentMode: { type: String, default: 'Cash' },
    description: { type: String, default: '' },
    createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  },
  { timestamps: true }
);

export default mongoose.model('Expense', expenseSchema);
