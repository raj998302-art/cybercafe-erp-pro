import { Router } from 'express';
import Supplier from '../models/Supplier.js';
import { sendSuccess, sendError } from '../utils/response.js';

const router = Router();

router.get('/', async (req, res, next) => {
  try {
    const { q } = req.query;
    const filter = q ? { name: { $regex: q, $options: 'i' } } : {};
    const items = await Supplier.find(filter).sort({ name: 1 });
    return sendSuccess(res, items);
  } catch (err) {
    next(err);
  }
});

router.get('/:id', async (req, res, next) => {
  try {
    const doc = await Supplier.findById(req.params.id);
    if (!doc) return sendError(res, 404, 'Supplier not found');
    return sendSuccess(res, doc);
  } catch (err) {
    next(err);
  }
});

router.post('/', async (req, res, next) => {
  try {
    const doc = await Supplier.create(req.body);
    return sendSuccess(res, doc, 'Supplier created', 201);
  } catch (err) {
    next(err);
  }
});

router.put('/:id', async (req, res, next) => {
  try {
    const doc = await Supplier.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    });
    if (!doc) return sendError(res, 404, 'Supplier not found');
    return sendSuccess(res, doc, 'Supplier updated');
  } catch (err) {
    next(err);
  }
});

router.delete('/:id', async (req, res, next) => {
  try {
    const doc = await Supplier.findByIdAndDelete(req.params.id);
    if (!doc) return sendError(res, 404, 'Supplier not found');
    return sendSuccess(res, null, 'Supplier deleted');
  } catch (err) {
    next(err);
  }
});

export default router;
