import { Router } from 'express';
import Customer from '../models/Customer.js';
import { sendSuccess, sendError } from '../utils/response.js';

const router = Router();

router.get('/', async (req, res, next) => {
  try {
    const { q, page = 1, limit = 100 } = req.query;
    const filter = {};
    if (q) {
      filter.$or = [
        { name: { $regex: q, $options: 'i' } },
        { phone: { $regex: q, $options: 'i' } },
        { gstin: { $regex: q, $options: 'i' } },
      ];
    }
    const skip = (Number(page) - 1) * Number(limit);
    const items = await Customer.find(filter).sort({ name: 1 }).skip(skip).limit(Number(limit));
    const total = await Customer.countDocuments(filter);
    return sendSuccess(res, { items, total, page: Number(page), limit: Number(limit) });
  } catch (err) {
    next(err);
  }
});

router.get('/search', async (req, res, next) => {
  try {
    const q = req.query.q || '';
    const items = await Customer.find({
      $or: [
        { name: { $regex: q, $options: 'i' } },
        { phone: { $regex: q, $options: 'i' } },
      ],
    }).limit(20);
    return sendSuccess(res, items);
  } catch (err) {
    next(err);
  }
});

router.get('/:id', async (req, res, next) => {
  try {
    const doc = await Customer.findById(req.params.id);
    if (!doc) return sendError(res, 404, 'Customer not found');
    return sendSuccess(res, doc);
  } catch (err) {
    next(err);
  }
});

router.post('/', async (req, res, next) => {
  try {
    const doc = await Customer.create(req.body);
    return sendSuccess(res, doc, 'Customer created', 201);
  } catch (err) {
    next(err);
  }
});

router.put('/:id', async (req, res, next) => {
  try {
    const doc = await Customer.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    });
    if (!doc) return sendError(res, 404, 'Customer not found');
    return sendSuccess(res, doc, 'Customer updated');
  } catch (err) {
    next(err);
  }
});

router.delete('/:id', async (req, res, next) => {
  try {
    const doc = await Customer.findByIdAndDelete(req.params.id);
    if (!doc) return sendError(res, 404, 'Customer not found');
    return sendSuccess(res, null, 'Customer deleted');
  } catch (err) {
    next(err);
  }
});

export default router;
