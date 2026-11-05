const test = require('node:test');
const assert = require('node:assert');
const { evaluate, render } = require('./pr-check.cjs');

const body = (why, type = '- [x] Feature (`feat`)') =>
  `## What and why\n${why}\n\nCloses #3\n\n## Type of change\n${type}\n\n## How I tested it\n- [x] CI is green\n`;
const file = (filename, patch = '', additions = 5) => ({ filename, additions, deletions: 0, patch });
const base = { title: 'feat(US-03): approve with comment', head: 'feature/us-03-approve', base: 'develop', body: body('Adds an optional comment when approving a request.') };

test('clean PR passes', () => {
  const r = evaluate({ ...base, files: [file('srv/procurement-service.js'), file('test/procurement/a.test.js')] });
  assert.ok(r.ok); assert.deepStrictEqual(r.warn, []); assert.ok(r.labels.includes('workstream: procurement'));
});

test('bad title, branch and empty description fail', () => {
  const r = evaluate({ ...base, title: 'updates', head: 'my-branch', body: '## What and why\n\nCloses #\n', files: [] });
  assert.strictEqual(r.fail.length, 4); assert.ok(!r.ok);
});

test('feature PR into main is rejected', () => {
  assert.ok(evaluate({ ...base, base: 'main', files: [] }).fail.some(m => m.includes('Only `develop`')));
});

test('warnings: cross-workstream, no tests, contract, unprotected action, secret', () => {
  const r = evaluate({ ...base, files: [
    file('srv/procurement-service.js'), file('srv/supplier-service.cds', '+  action blockAll();'),
    file('db/schema.cds'), file('srv/x.js', '+const k = "-----BEGIN RSA ' + 'PRIVATE KEY-----"'),   // split so pr-check does not flag its own test
  ] });
  assert.ok(r.labels.includes('cross-workstream') && r.labels.includes('contract-change'));
  assert.ok(r.warn.length >= 4 && r.fail.some(m => m.includes('secret')));
  assert.match(render(r), /❌ PR check failed/);
});

test('dependabot PRs skip the template rules', () => {
  const r = evaluate({ title: 'chore(deps): bump actions/checkout from 4 to 7', head: 'dependabot/github_actions/develop/actions/checkout-7', base: 'develop', body: 'Bumps actions/checkout.', files: [file('.github/workflows/ci.yml')] });
  assert.ok(r.ok); assert.deepStrictEqual(r.warn, []);
});
