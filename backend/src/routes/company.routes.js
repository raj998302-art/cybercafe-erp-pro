import { Router } from 'express';
import Company from '../models/Company.js';
import { sendSuccess, sendError } from '../utils/response.js';

const router = Router();

router.get('/', async (_req, res, next) => {
  try {
    const company = await Company.findOne();
    return sendSuccess(res, company);
  } catch (err) {
    next(err);
  }
});

router.put('/', async (req, res, next) => {
  try {
    const body = req.body;
    // Prevent overwriting immutable fields
    delete body._id;
    delete body.__v;
    delete body.createdAt;
    const company = await Company.findOne();
    if (company) {
      Object.assign(company, body);
      await company.save();
      return sendSuccess(res, company, 'Company updated');
    }
    const created = await Company.create(body);
    return sendSuccess(res, created, 'Company created', 201);
  } catch (err) {
    next(err);
  }
});

export default router;
