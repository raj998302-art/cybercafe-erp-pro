import { Router } from 'express';
import mongoose from 'mongoose';
import { protect } from '../middleware/auth.js';
import { sendSuccess } from '../utils/response.js';

const router = Router();

const MODELS = ['Company', 'Customer', 'Supplier', 'Item', 'Bill',
  'Voucher', 'Ledger', 'Expense', 'AuditLog'];
// NOTE: 'User' is excluded from export to prevent passwordHash leakage.

router.post('/export', protect, async (_req, res, next) => {
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

router.post('/import', protect, async (req, res, next) => {
  try {
    // Only admins can import (destructive operation)
    if (req.user?.role !== 'admin') {
      return res.status(403).json({ success: false, message: 'Admin access required for import' });
    }
    const data = req.body;
    const counts = {};
    for (const name of MODELS) {
      if (!Array.isArray(data[name])) continue;
      const Model = mongoose.model(name);
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
