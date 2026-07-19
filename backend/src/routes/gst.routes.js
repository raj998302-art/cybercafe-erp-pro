import { Router } from 'express';
import Bill from '../models/Bill.js';
import Expense from '../models/Expense.js';
import { sendSuccess } from '../utils/response.js';
import { formatGSTR1, formatGSTR3B } from '../services/gst.service.js';

const router = Router();

router.get('/gstr1', async (req, res, next) => {
  try {
    const { from, to } = req.query;
    const now = new Date();
    const start = from ? new Date(from) : new Date(now.getFullYear(), now.getMonth(), 1);
    const end = to ? new Date(`${to}T23:59:59`) : new Date(now.getFullYear(), now.getMonth() + 1, 0, 23, 59, 59);
    const bills = await Bill.find({ billDate: { $gte: start, $lte: end } });
    return sendSuccess(res, { period: { from: start, to: end }, gstr1: formatGSTR1(bills) });
  } catch (err) {
    next(err);
  }
});

router.get('/gstr3b', async (req, res, next) => {
  try {
    const month = req.query.month; // YYYY-MM
    const now = month ? new Date(`${month}-01`) : new Date();
    const start = new Date(now.getFullYear(), now.getMonth(), 1);
    const end = new Date(now.getFullYear(), now.getMonth() + 1, 0, 23, 59, 59);
    const bills = await Bill.find({ billDate: { $gte: start, $lte: end } });
    const expenses = await Expense.find({ date: { $gte: start, $lte: end } });
    return sendSuccess(res, {
      period: { month: `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}` },
      gstr3b: formatGSTR3B(bills, expenses),
    });
  } catch (err) {
    next(err);
  }
});

export default router;
