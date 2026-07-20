import { Router } from 'express';
import Item from '../models/Item.js';
import { sendSuccess, sendError } from '../utils/response.js';
import { seedDefaultItems } from '../services/seed.service.js';

const router = Router();

router.get('/', async (req, res, next) => {
  try {
    const { q, onlyActive } = req.query;
    const filter = {};
    if (onlyActive === 'true') filter.active = true;
    if (q) {
      filter.$or = [
        { name: { $regex: q, $options: 'i' } },
        { shortName: { $regex: q, $options: 'i' } },
      ];
    }
    const items = await Item.find(filter).sort({ sortOrder: 1, name: 1 });
    return sendSuccess(res, items);
  } catch (err) {
    next(err);
  }
});

router.get('/seed', async (_req, res, next) => {
  try {
    const result = await seedDefaultItems();
    return sendSuccess(res, result, 'Seed completed');
  } catch (err) {
    next(err);
  }
});

router.get('/:id', async (req, res, next) => {
  try {
    const doc = await Item.findById(req.params.id);
    if (!doc) return sendError(res, 404, 'Item not found');
    return sendSuccess(res, doc);
  } catch (err) {
    next(err);
  }
});

router.post('/', async (req, res, next) => {
  try {
    const doc = await Item.create(req.body);
    return sendSuccess(res, doc, 'Item created', 201);
  } catch (err) {
    next(err);
  }
});

router.put('/:id', async (req, res, next) => {
  try {
    const doc = await Item.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    });
    if (!doc) return sendError(res, 404, 'Item not found');
    return sendSuccess(res, doc, 'Item updated');
  } catch (err) {
    next(err);
  }
});

router.put('/:id/toggle-active', async (req, res, next) => {
  try {
    const doc = await Item.findById(req.params.id);
    if (!doc) return sendError(res, 404, 'Item not found');
    doc.active = !doc.active;
    await doc.save();
    return sendSuccess(res, doc, `Item ${doc.active ? 'activated' : 'hidden'}`);
  } catch (err) {
    next(err);
  }
});

router.delete('/:id', async (req, res, next) => {
  try {
    const doc = await Item.findByIdAndDelete(req.params.id);
    if (!doc) return sendError(res, 404, 'Item not found');
    return sendSuccess(res, null, 'Item deleted');
  } catch (err) {
    next(err);
  }
});

export default router;
