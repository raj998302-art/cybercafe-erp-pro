import User from '../models/User.js';
import Item from '../models/Item.js';
import { DEFAULT_ITEMS } from '../config/constants.js';
import { logger } from '../utils/logger.js';

export async function seedDefaultItems() {
  const count = await Item.countDocuments();
  if (count > 0) {
    logger.info(`Seed skipped — ${count} items already exist`);
    return { skipped: true, count };
  }
  const docs = DEFAULT_ITEMS.map((d, i) => ({
    ...d,
    stockQty: 0,
    minStock: 0,
    isService: true,
    active: true,
    sortOrder: i,
  }));
  await Item.insertMany(docs);
  logger.info(`Seeded ${docs.length} default cyber cafe items`);
  return { inserted: docs.length };
}

export async function seedDefaultAdmin() {
  const exists = await User.findOne({ username: 'admin' });
  if (exists) {
    logger.info('Default admin user already exists');
    return { skipped: true };
  }
  const admin = new User({
    username: 'admin',
    passwordHash: 'admin123',
    name: 'Administrator',
    role: 'admin',
  });
  await admin.save();
  logger.info('Default admin user created (admin / admin123)');
  return { created: true };
}

export async function runAllSeeds() {
  await seedDefaultAdmin();
  await seedDefaultItems();
}
