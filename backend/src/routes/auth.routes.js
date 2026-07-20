import { Router } from 'express';
import bcrypt from 'bcryptjs';
import User from '../models/User.js';
import { signToken, protect } from '../middleware/auth.js';
import { sendSuccess, sendError } from '../utils/response.js';
import { seedDefaultAdmin } from '../services/seed.service.js';

const router = Router();

router.post('/login', async (req, res, next) => {
  try {
    const { username, password } = req.body;
    if (!username || !password) {
      return sendError(res, 400, 'Username and password required');
    }
    const user = await User.findOne({ username: username.toLowerCase() });
    if (!user || !user.active) {
      return sendError(res, 401, 'Invalid credentials');
    }
    const ok = await user.comparePassword(password);
    if (!ok) {
      return sendError(res, 401, 'Invalid credentials');
    }
    user.lastLogin = new Date();
    await user.save();
    const token = signToken(user._id);
    return sendSuccess(res, { token, user }, 'Login successful');
  } catch (err) {
    next(err);
  }
});

router.post('/register', protect, async (req, res, next) => {
  try {
    const { username, password, name, role } = req.body;
    if (!username || !password || !name) {
      return sendError(res, 400, 'username, password and name are required');
    }
    // Only admins can create new users; non-admins can only create 'viewer'
    const allowedRole = req.user?.role === 'admin' ? (role || 'operator') : 'viewer';
    const exists = await User.findOne({ username: username.toLowerCase() });
    if (exists) {
      return sendError(res, 409, 'Username already exists');
    }
    const user = new User({
      username: username.toLowerCase(),
      passwordHash: password,
      name,
      role: allowedRole,
    });
    await user.save();
    const token = signToken(user._id);
    return sendSuccess(res, { token, user }, 'User registered', 201);
  } catch (err) {
    next(err);
  }
});

router.get('/me', protect, async (req, res, next) => {
  try {
    return sendSuccess(res, { user: req.user });
  } catch (err) {
    next(err);
  }
});

router.post('/change-password', protect, async (req, res, next) => {
  try {
    const { currentPassword, newPassword } = req.body;
    const ok = await req.user.comparePassword(currentPassword);
    if (!ok) return sendError(res, 401, 'Current password is incorrect');
    req.user.passwordHash = newPassword;
    await req.user.save();
    return sendSuccess(res, null, 'Password changed');
  } catch (err) {
    next(err);
  }
});

router.post('/seed-admin', async (_req, res, next) => {
  try {
    const result = await seedDefaultAdmin();
    return sendSuccess(res, result, 'Seed admin done');
  } catch (err) {
    next(err);
  }
});

export default router;
