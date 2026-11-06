# Allow teams of exactly 4 members (fix off-by-one in member count validation)

## Summary

The rules say **teams of up to 4 people**, and the form hint says "Up to 4 people", but `isValidMemberCount` used a strict `count < MAX_MEMBERS` comparison. That rejected 4, so a full team saw "Teams can have 1 to 4 members." and couldn't submit. This PR makes the upper bound inclusive and adds a regression test.

## Changes

- `app.js`
  - `isValidMemberCount`: `count < MAX_MEMBERS` → `count <= MAX_MEMBERS`.
  - The doc comment now says the range is inclusive.
- `tests/validation.test.js`
  - New test: **accepts a team of exactly 4 members, the maximum the rules allow** (number `4`, string `'4'`, and padded `' 4 '`).
  - Existing tests are unchanged and still reject `0`, `5`, `10`, decimals and non-numbers.

## Testing

- ✅ `node --test`: 13 of 13 tests pass (12 existing, 1 new).
- ✅ The new test fails on the old code and passes on this branch.
- ✅ Submitting the form with 4 members now shows the confirmation. 5 members still shows the error.

## Risk

Low. A one-character logic fix, backed by a test that pins the boundary.
