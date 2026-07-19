import { Router } from 'express';
import mongoose from 'mongoose';
import { sendSuccess } from '../utils/response.js';
import { runAllSeeds } from '../services/seed.service.js';

const router = Router();

const SYNC_MODELS = ['Company', 'Customer', 'Supplier', 'Item', 'Bill',
  'Voucher', 'Ledger', 'Expense'];

router.get('/all', async (_req, res, next) => {
  try {
    const out = {};
    for (const name of SYNC_MODELS) {
      const Model = mongoose.model(name);
      out[name] = await Model.find().lean();
    }
    return sendSuccess(res, out, 'Sync dump ready');
  } catch (err) {
    next(err);
  }
});

router.post('/push', async (req, res, next) => {
  try {
    const data = req.body || {};
    const counts = {};
    for (const name of SYNC_MODELS) {
      if (!Array.isArray(data[name])) continue;
      const Model = mongoose.model(name);
      // Upsert by _id
      let n = 0;
      for (const doc of data[name]) {
        if (!doc._id) continue;
        await Model.updateOne({ _id: doc._id }, { $set: doc }, { upsert: true });
        n++;
      }
      counts[name] = n;
    }
    return sendSuccess(res, counts, 'Push complete');
  } catch (err) {
    next(err);
  }
});

router.post('/seed', async (_req, res, next) => {
  try {
    const result = await runAllSeeds();
    return sendSuccess(res, result, 'Seeds applied');
  } catch (err) {
    next(err);
  }
});

export default router;
