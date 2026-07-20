import { Router } from 'express';
import Bill from '../models/Bill.js';
import Customer from '../models/Customer.js';
import Company from '../models/Company.js';
import { sendSuccess, sendError } from '../utils/response.js';
import { generateBillNumber, recalcBillTotals } from '../services/bill.service.js';
import { isStateSame } from '../services/gst.service.js';

const router = Router();

// List bills with optional date filters
router.get('/', async (req, res, next) => {
  try {
    const { q, from, to, limit = 200 } = req.query;
    const filter = {};
    if (q) filter.billNumber = { $regex: q, $options: 'i' };
    if (from || to) {
      filter.billDate = {};
      if (from) filter.billDate.$gte = new Date(from);
      if (to) filter.billDate.$lte = new Date(`${to}T23:59:59`);
    }
    const items = await Bill.find(filter)
      .sort({ billDate: -1 })
      .limit(Number(limit))
      .populate('customer', 'name phone gstin');
    return sendSuccess(res, items);
  } catch (err) {
    next(err);
  }
});

router.get('/today/count', async (_req, res, next) => {
  try {
    const start = new Date();
    start.setHours(0, 0, 0, 0);
    const end = new Date();
    end.setHours(23, 59, 59, 999);
    const count = await Bill.countDocuments({ billDate: { $gte: start, $lte: end } });
    const total = await Bill.aggregate([
      { $match: { billDate: { $gte: start, $lte: end } } },
      { $group: { _id: null, total: { $sum: '$grandTotal' } } },
    ]);
    return sendSuccess(res, { count, totalSales: total[0]?.total || 0 });
  } catch (err) {
    next(err);
  }
});

router.get('/month/summary', async (_req, res, next) => {
  try {
    const now = new Date();
    const start = new Date(now.getFullYear(), now.getMonth(), 1);
    const end = new Date(now.getFullYear(), now.getMonth() + 1, 0, 23, 59, 59);
    const agg = await Bill.aggregate([
      { $match: { billDate: { $gte: start, $lte: end } } },
      {
        $group: {
          _id: null,
          count: { $sum: 1 },
          totalSales: { $sum: '$grandTotal' },
          totalGst: { $sum: '$totalGst' },
          totalDiscount: { $sum: '$totalDiscount' },
        },
      },
    ]);
    return sendSuccess(res, agg[0] || { count: 0, totalSales: 0, totalGst: 0, totalDiscount: 0 });
  } catch (err) {
    next(err);
  }
});

router.get('/:id', async (req, res, next) => {
  try {
    const doc = await Bill.findById(req.params.id).populate('customer items.itemId');
    if (!doc) return sendError(res, 404, 'Bill not found');
    return sendSuccess(res, doc);
  } catch (err) {
    next(err);
  }
});

router.post('/', async (req, res, next) => {
  try {
    const body = req.body;
    const company = await Company.findOne();
    const customer = body.customer ? await Customer.findById(body.customer) : null;
    const intra = isStateSame(company?.address?.state, customer?.state);

    const items = body.items || [];
    const totals = recalcBillTotals(items, intra);

    const billNumber = body.billNumber || (await generateBillNumber());

    const doc = await Bill.create({
      ...body,
      billNumber,
      customerSnapshot: customer
        ? {
            name: customer.name,
            phone: customer.phone,
            gstin: customer.gstin,
            address: customer.address,
            state: customer.state,
          }
        : body.customerSnapshot || {},
      items,
      ...totals,
      balanceDue: (totals.grandTotal) - (body.paidAmount || 0),
      paymentStatus:
        (body.paidAmount || 0) >= totals.grandTotal
          ? 'paid'
          : body.paidAmount > 0
            ? 'partial'
            : 'unpaid',
      company: company?._id,
    });

    return sendSuccess(res, doc, 'Bill created', 201);
  } catch (err) {
    next(err);
  }
});

router.put('/:id', async (req, res, next) => {
  try {
    const doc = await Bill.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    });
    if (!doc) return sendError(res, 404, 'Bill not found');
    return sendSuccess(res, doc, 'Bill updated');
  } catch (err) {
    next(err);
  }
});

router.delete('/:id', async (req, res, next) => {
  try {
    const doc = await Bill.findByIdAndDelete(req.params.id);
    if (!doc) return sendError(res, 404, 'Bill not found');
    return sendSuccess(res, null, 'Bill deleted');
  } catch (err) {
    next(err);
  }
});

export default router;
