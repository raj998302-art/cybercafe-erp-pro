import { Router } from 'express';
import mongoose from 'mongoose';
import { sendSuccess } from '../utils/response.js';

const router = Router();

const MODELS = ['User', 'Company', 'Customer', 'Supplier', 'Item', 'Bill',
  'Voucher', 'Ledger', 'Expense', 'AuditLog'];

router.post('/export', async (_req, res, next) => {
  try {
    const out = { meta: { exportedAt: new Date().toISOString(), app: 'CyberCafe ERP Pro' } };
    for (const name of MODELS) {
      const Model = mongoose.model(name);
      out[name] = await Model.find().lean();
    }
    return sendSuccess(res, out, 'Export complete');
  } catch (err) {
    next(err);
  }
});

router.post('/import', async (req, res, next) => {
  try {
    const data = req.body;
    const counts = {};
    for (const name of MODELS) {
      if (!Array.isArray(data[name])) continue;
      const Model = mongoose.model(name);
      // Replace collection
      await Model.deleteMany({});
      if (data[name].length) await Model.insertMany(data[name]);
      counts[name] = data[name].length;
    }
    return sendSuccess(res, counts, 'Import complete');
  } catch (err) {
    next(err);
  }
});

export default router;
