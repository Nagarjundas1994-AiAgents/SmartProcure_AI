// Pure rules for the PR gate: no network, so it is unit-testable. The workflow feeds it the PR and its files.
// "fail" blocks the PR check, "warn" is advice the reviewer should look at, "info" is context.

const TITLE = /^(feat|fix|docs|chore|refactor|test|ci|build|perf|revert)(\([\w.-]+\))?!?: \S.{3,}/;
const BRANCH = /^(feature\/us-\d+-[a-z0-9-]+|fix\/|chore\/|docs\/|hotfix\/|release\/|dependabot\/)/;
// Workstream paths mirror .github/CODEOWNERS.
const DEV1 = /^(srv\/procurement|srv\/lib\/receipts|srv\/integrations\/s4-sync|app\/procurement-ui|test\/procurement)/;
const DEV2 = /^(srv\/supplier|srv\/lib\/scoring|srv\/integrations\/(supplier-portal|csv-import)|srv\/(mcp|agents)\/|mocks\/|app\/supplier-ui|test\/(supplier|agents)\/)/;
const CONTRACT = /^(db\/|srv\/[^/]+\.cds$|srv\/external\/|xs-security\.json$|mta\.yaml$|docs\/api-contracts\/)/;
const SOURCE = /^(srv|app|db)\//;
const TEST = /(^test\/|\.test\.[jt]s$)/;
const SECRET = /-----BEGIN [A-Z ]*PRIVATE KEY-----|\b(?:ghp|github_pat|xox[bp])_[A-Za-z0-9_-]{20,}|"clientsecret"\s*:\s*"[^"]{8,}"/i;

function section(body, heading) {
  const m = new RegExp(`##\\s*${heading}[^\\n]*\\n([\\s\\S]*?)(?=\\n##\\s|$)`, 'i').exec(body || '');
  return m ? m[1].replace(/<!--[\s\S]*?-->/g, '').trim() : '';
}

function evaluate({ title, body, head, base, files }) {
  const f = [], w = [], i = [], labels = new Set();
  const add = (list, msg) => list.push(msg);

  if (!TITLE.test(title)) add(f, 'Title must follow Conventional Commits, e.g. `feat(US-03): approve with comment` (it becomes the squash-commit message).');
  if (!BRANCH.test(head) && !(head === 'develop' && base === 'main'))
    add(f, `Branch \`${head}\` does not match the naming rule (\`feature/us-NN-name\`, \`fix/\`, \`chore/\`, \`docs/\`, \`hotfix/\`).`);
  if (base === 'main' && head !== 'develop' && !head.startsWith('hotfix/'))
    add(f, 'Only `develop` (release) or `hotfix/*` may target `main`. Open this PR into `develop`.');

  const why = section(body, 'What and why').replace(/closes\s+#\s*$/im, '').trim();
  if (why.length < 20) add(f, 'Fill in **What and why** (at least a sentence, and link the issue with `Closes #NN`).');
  const typeBlock = section(body, 'Type of change');
  if (!/\[[xX]\]/.test(typeBlock)) add(f, 'Tick one **Type of change** box.');
  if (!/\[[xX]\]\s*I tried it manually|\[[xX]\]\s*CI is green/.test(section(body, 'How I tested it')))
    add(w, 'No evidence in **How I tested it**. Say how you checked the change.');

  const changed = files.reduce((n, x) => n + x.additions + x.deletions, 0);
  const names = files.map(x => x.filename);
  const dev1 = names.filter(n => DEV1.test(n)), dev2 = names.filter(n => DEV2.test(n));
  const contract = names.filter(n => CONTRACT.test(n));

  if (dev1.length) labels.add('workstream: procurement');
  if (dev2.length) labels.add('workstream: supplier');
  if (dev1.length && dev2.length) { labels.add('cross-workstream'); add(w, 'Touches **both** workstreams (procurement and supplier). Split the PR, or tag the other developer as reviewer and explain why.'); }
  if (contract.length) {
    labels.add('contract-change');
    add(w, `Contract/security files changed (${contract.slice(0, 5).map(n => `\`${n}\``).join(', ')}${contract.length > 5 ? ', …' : ''}). Tick *Contract change*, update \`docs/api-contracts\`, tell the other developer.`);
    if (!/\[[xX]\]\s*Contract change/.test(typeBlock)) add(w, '"Contract change" is not ticked in **Type of change**.');
  }

  labels.add(changed <= 100 ? 'size: S' : changed <= 400 ? 'size: M' : 'size: L');
  if (changed > 400) add(w, `${changed} lines changed. Large PRs get shallow reviews; please split it.`);

  const src = names.filter(n => SOURCE.test(n) && !TEST.test(n)), tests = names.filter(n => TEST.test(n));
  if (src.length && !tests.length) add(w, 'Source changed but no test was added or updated.');
  if (names.includes('package-lock.json') && !names.includes('package.json') && !head.startsWith('dependabot/'))
    add(w, '`package-lock.json` changed without `package.json`. Was that intended?');

  for (const x of files) {
    const added = (x.patch || '').split('\n').filter(l => l.startsWith('+') && !l.startsWith('+++'));
    if (added.some(l => SECRET.test(l))) add(f, `Possible secret in \`${x.filename}\`. Remove it and **rotate** it; deleting it in a later commit is not enough.`);
    if (/\.(js|ts)$/.test(x.filename) && !TEST.test(x.filename) && added.some(l => /\bconsole\.log\(|\bdebugger\b/.test(l)))
      add(w, `Debug leftover (\`console.log\`/\`debugger\`) in \`${x.filename}\`; use \`cds.log\`.`);
    if (TEST.test(x.filename) && added.some(l => /\b(it|test|describe)\.only\(/.test(l))) add(f, `\`.only\` left in \`${x.filename}\`; it silently skips the other tests.`);
    if (/^srv\/.*\.cds$/.test(x.filename)) {
      const acts = added.map(l => /^\+\s*(?:bound\s+)?(action|function)\s+(\w+)/.exec(l)).filter(Boolean).map(m => m[2]);
      if (acts.length && !/@requires|@restrict/.test(x.patch || ''))
        add(w, `New ${acts.map(a => `\`${a}\``).join(', ')} in \`${x.filename}\` but no \`@requires\`/\`@restrict\` in the diff. Confirm authorization is inherited from the service.`);
    }
  }

  add(i, `${files.length} file(s), ${changed} line(s) changed. Reviewers: code owners are requested automatically.`);
  return { fail: f, warn: w, info: i, labels: [...labels], ok: f.length === 0 };
}

function render(r) {
  const list = (items, icon) => items.map(m => `- ${icon} ${m}`).join('\n');
  return [
    '<!-- pr-check -->',
    `### ${r.ok ? '✅ PR check passed' : '❌ PR check failed'}`,
    r.fail.length ? `**Must fix before review**\n${list(r.fail, '❌')}` : '',
    r.warn.length ? `**Reviewer attention**\n${list(r.warn, '⚠️')}` : '',
    list(r.info, 'ℹ️'),
    '_Automated by `.github/workflows/pr-check.yml`. This comment updates when you push or edit the PR._',
  ].filter(Boolean).join('\n\n');
}

module.exports = { evaluate, render };
