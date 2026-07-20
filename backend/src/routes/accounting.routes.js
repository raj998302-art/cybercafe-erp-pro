import { Router } from 'express';
import Voucher from '../models/Voucher.js';
import Ledger from '../models/Ledger.js';
import { sendSuccess, sendError } from '../utils/response.js';

const router = Router();

router.get('/ledgers', async (req, res, next) => {
  try {
    const { q } = req.query;
    const filter = q ? { name: { $regex: q, $options: 'i' } } : {};
    const items = await Ledger.find(filter).sort({ name: 1 });
    return sendSuccess(res, items);
  } catch (err) {
    next(err);
  }
});

router.post('/ledgers', async (req, res, next) => {
  try {
    const doc = await Ledger.create(req.body);
    return sendSuccess(res, doc, 'Ledger created', 201);
  } catch (err) {
    next(err);
  }
});

router.get('/vouchers', async (req, res, next) => {
  try {
    const { from, to, limit = 200 } = req.query;
    const filter = {};
    if (from || to) {
      filter.date = {};
      if (from) filter.date.$gte = new Date(from);
      if (to) filter.date.$lte = new Date(`${to}T23:59:59`);
    }
    const items = await Voucher.find(filter).sort({ date: -1 }).limit(Number(limit));
    return sendSuccess(res, items);
  } catch (err) {
    next(err);
  }
});

router.post('/vouchers', async (req, res, next) => {
  try {
    const body = req.body;
    const count = await Voucher.countDocuments({ voucherType: body.voucherType });
    const vno = body.voucherNumber || `${body.voucherType?.substring(0, 3).toUpperCase()}-${count + 1}`;
    const doc = await Voucher.create({
      ...body,
      voucherNumber: vno,
      amount: body.entries?.reduce((s, e) => s + (e.debit || 0), 0) || 0,
    });
    return sendSuccess(res, doc, 'Voucher created', 201);
  } catch (err) {
    next(err);
  }
});

router.get('/daybook', async (req, res, next) => {
  try {
    const { date } = req.query;
    const day = date ? new Date(date) : new Date();
    const start = new Date(day.setHours(0, 0, 0, 0));
    const end = new Date(day.setHours(23, 59, 59, 999));
    const items = await Voucher.find({ date: { $gte: start, $lte: end } }).sort({ date: 1 });
    return sendSuccess(res, items);
  } catch (err) {
    next(err);
  }
});

router.get('/trial-balance', async (_req, res, next) => {
  try {
    const ledgers = await Ledger.find();
    const rows = ledgers.map((l) => ({
      name: l.name,
      group: l.group,
      debit: l.balanceType === 'debit' ? l.openingBalance : 0,
      credit: l.balanceType === 'credit' ? l.openingBalance : 0,
    }));
    const totalDebit = rows.reduce((s, r) => s + r.debit, 0);
    const totalCredit = rows.reduce((s, r) => s + r.credit, 0);
    return sendSuccess(res, { rows, totalDebit, totalCredit });
  } catch (err) {
    next(err);
  }
});

export default router;
