import { Router } from 'express';
import Expense from '../models/Expense.js';
import { sendSuccess, sendError } from '../utils/response.js';

const router = Router();

router.get('/', async (req, res, next) => {
  try {
    const { from, to, limit = 200 } = req.query;
    const filter = {};
    if (from || to) {
      filter.date = {};
      if (from) filter.date.$gte = new Date(from);
      if (to) filter.date.$lte = new Date(`${to}T23:59:59`);
    }
    const items = await Expense.find(filter).sort({ date: -1 }).limit(Number(limit));
    return sendSuccess(res, items);
  } catch (err) {
    next(err);
  }
});

router.post('/', async (req, res, next) => {
  try {
    const doc = await Expense.create(req.body);
    return sendSuccess(res, doc, 'Expense created', 201);
  } catch (err) {
    next(err);
  }
});

router.put('/:id', async (req, res, next) => {
  try {
    const doc = await Expense.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!doc) return sendError(res, 404, 'Expense not found');
    return sendSuccess(res, doc, 'Expense updated');
  } catch (err) {
    next(err);
  }
});

router.delete('/:id', async (req, res, next) => {
  try {
    const doc = await Expense.findByIdAndDelete(req.params.id);
    if (!doc) return sendError(res, 404, 'Expense not found');
    return sendSuccess(res, null, 'Expense deleted');
  } catch (err) {
    next(err);
  }
});

export default router;
