'use strict';

const { test } = require('node:test');
const assert = require('node:assert/strict');
const {
  isValidMemberCount,
  isValidEmail,
  isValidRepoUrl,
  validateSubmission,
} = require('../app.js');

test('accepts small teams', () => {
  for (const value of [1, 2, 3, '1', '2', '3', ' 2 ']) {
    assert.equal(isValidMemberCount(value), true, `expected ${JSON.stringify(value)} to be valid`);
  }
});

test('accepts a team of exactly 4 members, the maximum the rules allow', () => {
  assert.equal(isValidMemberCount(4), true);
  assert.equal(isValidMemberCount('4'), true);
  assert.equal(isValidMemberCount(' 4 '), true);
});

test('rejects member counts outside the allowed range or not whole numbers', () => {
  for (const value of [0, -1, 5, 10, 2.5, '2.5', '', ' ', 'abc', null, undefined]) {
    assert.equal(isValidMemberCount(value), false, `expected ${JSON.stringify(value)} to be invalid`);
  }
});

test('accepts normal email addresses', () => {
  for (const value of ['team@shipfest.dev', 'a.b+c@example.co.in', '  lead@team.io  ']) {
    assert.equal(isValidEmail(value), true, `expected ${JSON.stringify(value)} to be valid`);
  }
});

test('rejects malformed email addresses', () => {
  for (const value of ['', 'no-at-sign', 'a@b', 'a @b.com', '@example.com', 'name@', null]) {
    assert.equal(isValidEmail(value), false, `expected ${JSON.stringify(value)} to be invalid`);
  }
});

test('accepts http and https repository URLs only', () => {
  assert.equal(isValidRepoUrl('https://github.com/team/project'), true);
  assert.equal(isValidRepoUrl('http://gitlab.com/team/project'), true);
  assert.equal(isValidRepoUrl('github.com/team/project'), false);
  assert.equal(isValidRepoUrl('ftp://example.com/repo'), false);
  assert.equal(isValidRepoUrl(''), false);
});

test('validateSubmission returns no errors for a valid submission', () => {
  const errors = validateSubmission({
    teamName: 'Night Owls',
    memberCount: '3',
    email: 'owls@example.com',
    repoUrl: 'https://github.com/night-owls/shipfest',
  });
  assert.deepEqual(errors, {});
});

test('validateSubmission reports every invalid field', () => {
  const errors = validateSubmission({ teamName: '', memberCount: '9', email: 'nope', repoUrl: 'nope' });
  assert.deepEqual(Object.keys(errors).sort(), ['email', 'memberCount', 'repoUrl', 'teamName']);
});
