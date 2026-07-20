import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import rateLimit from 'express-rate-limit';

import { connectDB } from './config/database.js';
import authRoutes from './routes/auth.routes.js';
import companyRoutes from './routes/company.routes.js';
import customerRoutes from './routes/customer.routes.js';
import supplierRoutes from './routes/supplier.routes.js';
import itemRoutes from './routes/item.routes.js';
import billRoutes from './routes/bill.routes.js';
import accountingRoutes from './routes/accounting.routes.js';
import expenseRoutes from './routes/expense.routes.js';
import reportRoutes from './routes/report.routes.js';
import gstRoutes from './routes/gst.routes.js';
import backupRoutes from './routes/backup.routes.js';
import syncRoutes from './routes/sync.routes.js';
import { errorHandler } from './middleware/errorHandler.js';
import { logger } from './utils/logger.js';

const app = express();
const PORT = process.env.PORT || 5000;

app.use(helmet());
app.use(cors({ origin: process.env.CLIENT_URL || '*' }));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));
app.use(morgan('dev'));

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 1000,
  standardHeaders: true,
  legacyHeaders: false,
});
app.use('/api', limiter);

app.get('/api/health', (_req, res) => {
  res.json({
    success: true,
    message: 'CyberCafe ERP Pro backend is running',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
  });
});

app.use('/api/auth', authRoutes);
app.use('/api/company', companyRoutes);
app.use('/api/customer', customerRoutes);
app.use('/api/supplier', supplierRoutes);
app.use('/api/item', itemRoutes);
app.use('/api/bill', billRoutes);
app.use('/api/accounting', accountingRoutes);
app.use('/api/expense', expenseRoutes);
app.use('/api/report', reportRoutes);
app.use('/api/gst', gstRoutes);
app.use('/api/backup', backupRoutes);
app.use('/api/sync', syncRoutes);

app.use((_req, res) => {
  res.status(404).json({ success: false, message: 'Route not found' });
});

app.use(errorHandler);

const start = async () => {
  try {
    await connectDB();
    app.listen(PORT, () => {
      logger.info(`CyberCafe ERP backend listening on http://localhost:${PORT}`);
    });
  } catch (err) {
    logger.error('Failed to start server:', err);
    process.exit(1);
  }
};

start();

process.on('unhandledRejection', (err) => {
  logger.error('Unhandled rejection:', err);
});
