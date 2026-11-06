'use strict';

const { test } = require('node:test');
const assert = require('node:assert/strict');
const { getTimeRemaining } = require('../app.js');

const deadline = new Date('2026-11-07T23:59:00+05:30');

test('splits the remaining time into days, hours, minutes and seconds', () => {
  const now = new Date(deadline.getTime() - ((1 * 24 + 2) * 3600 + 3 * 60 + 4) * 1000);
  const t = getTimeRemaining(deadline, now);
  assert.equal(t.days, 1);
  assert.equal(t.hours, 2);
  assert.equal(t.minutes, 3);
  assert.equal(t.seconds, 4);
});

test('counts whole days with no leftover hours', () => {
  const now = new Date(deadline.getTime() - 48 * 3600 * 1000);
  assert.deepEqual(getTimeRemaining(deadline, now), {
    total: 48 * 3600 * 1000,
    days: 2,
    hours: 0,
    minutes: 0,
    seconds: 0,
  });
});

test('rounds partial seconds down', () => {
  const now = new Date(deadline.getTime() - 999);
  const t = getTimeRemaining(deadline, now);
  assert.equal(t.total, 999);
  assert.equal(t.seconds, 0);
});

test('returns all zeros exactly at the deadline', () => {
  assert.deepEqual(getTimeRemaining(deadline, new Date(deadline.getTime())), {
    total: 0,
    days: 0,
    hours: 0,
    minutes: 0,
    seconds: 0,
  });
});

test('never goes negative after the deadline', () => {
  const now = new Date(deadline.getTime() + 5 * 60 * 1000);
  const t = getTimeRemaining(deadline, now);
  assert.equal(t.total, 0);
  assert.equal(t.days, 0);
  assert.equal(t.hours, 0);
  assert.equal(t.minutes, 0);
  assert.equal(t.seconds, 0);
});
