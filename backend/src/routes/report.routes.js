import { Router } from 'express';
import Bill from '../models/Bill.js';
import Expense from '../models/Expense.js';
import { sendSuccess } from '../utils/response.js';

const router = Router();

router.get('/sales-summary', async (req, res, next) => {
  try {
    const { from, to } = req.query;
    const start = from ? new Date(from) : new Date(new Date().getFullYear(), new Date().getMonth(), 1);
    const end = to ? new Date(`${to}T23:59:59`) : new Date();
    const agg = await Bill.aggregate([
      { $match: { billDate: { $gte: start, $lte: end } } },
      {
        $group: {
          _id: { $dateToString: { format: '%Y-%m-%d', date: '$billDate' } },
          count: { $sum: 1 },
          sales: { $sum: '$grandTotal' },
          gst: { $sum: '$totalGst' },
          discount: { $sum: '$totalDiscount' },
        },
      },
      { $sort: { _id: 1 } },
    ]);
    return sendSuccess(res, agg);
  } catch (err) {
    next(err);
  }
});

router.get('/gst-summary', async (req, res, next) => {
  try {
    const { from, to } = req.query;
    const start = from ? new Date(from) : new Date(new Date().getFullYear(), 0, 1);
    const end = to ? new Date(`${to}T23:59:59`) : new Date();
    const agg = await Bill.aggregate([
      { $match: { billDate: { $gte: start, $lte: end } } },
      {
        $group: {
          _id: null,
          totalTaxable: { $sum: { $subtract: ['$subtotal', '$totalDiscount'] } },
          totalCgst: { $sum: '$cgst' },
          totalSgst: { $sum: '$sgst' },
          totalIgst: { $sum: '$igst' },
          totalGst: { $sum: '$totalGst' },
          totalInvoiceValue: { $sum: '$grandTotal' },
        },
      },
    ]);
    return sendSuccess(res, agg[0] || {});
  } catch (err) {
    next(err);
  }
});

router.get('/top-customers', async (req, res, next) => {
  try {
    const limit = Number(req.query.limit || 10);
    const agg = await Bill.aggregate([
      { $group: { _id: '$customer', name: { $first: '$customerSnapshot.name' }, total: { $sum: '$grandTotal' }, count: { $sum: 1 } } },
      { $sort: { total: -1 } },
      { $limit: limit },
    ]);
    return sendSuccess(res, agg);
  } catch (err) {
    next(err);
  }
});

router.get('/top-items', async (req, res, next) => {
  try {
    const limit = Number(req.query.limit || 10);
    const agg = await Bill.aggregate([
      { $unwind: '$items' },
      {
        $group: {
          _id: '$items.name',
          qty: { $sum: '$items.qty' },
          amount: { $sum: '$items.total' },
        },
      },
      { $sort: { amount: -1 } },
      { $limit: limit },
    ]);
    return sendSuccess(res, agg);
  } catch (err) {
    next(err);
  }
});

router.get('/profit-loss', async (req, res, next) => {
  try {
    const { from, to } = req.query;
    const start = from ? new Date(from) : new Date(new Date().getFullYear(), 0, 1);
    const end = to ? new Date(`${to}T23:59:59`) : new Date();
    const salesAgg = await Bill.aggregate([
      { $match: { billDate: { $gte: start, $lte: end } } },
      { $group: { _id: null, total: { $sum: '$grandTotal' } } },
    ]);
    const expAgg = await Expense.aggregate([
      { $match: { date: { $gte: start, $lte: end } } },
      { $group: { _id: null, total: { $sum: '$amount' } } },
    ]);
    const sales = salesAgg[0]?.total || 0;
    const expenses = expAgg[0]?.total || 0;
    return sendSuccess(res, {
      period: { from: start, to: end },
      totalSales: sales,
      totalExpenses: expenses,
      netProfit: sales - expenses,
    });
  } catch (err) {
    next(err);
  }
});

export default router;
