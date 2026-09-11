#!/usr/bin/env python3
"""Fold one run's raw suite output into a single metrics.json.

Deliberately does no judgement: it records what happened and whether the rspec
failure SET matches the baseline. Classification against the rubric is a human
step, done later, from the diff.
"""
import json, os, pathlib, re, datetime

out = pathlib.Path(os.environ['OUT'])
known = set(filter(None, os.environ.get('KNOWN', '').split(',')))


def status(name):
    f = out / f'{name}.status'
    if not f.exists():
        return {'exit_code': None, 'duration_s': None}
    code, dur = f.read_text().split()
    return {'exit_code': int(code), 'duration_s': int(dur)}


def rspec_summary():
    f = out / 'rspec.json'
    if not f.exists():
        return {'parsed': False}
    d = json.loads(f.read_text())
    s = d['summary']
    failed = {f"{e['file_path']}:{e['line_number']}" for e in d['examples']
              if e['status'] == 'failed'}
    return {
        'parsed': True,
        'examples': s['example_count'],
        'failures': s['failure_count'],
        'pending': s['pending_count'],
        'rspec_reported_duration_s': round(s['duration'], 1),
        'failure_set': sorted(failed),
        'unexpected_failures': sorted(failed - known),
        'baseline_failures_missing': sorted(known - failed),
        'matches_baseline': failed == known,
    }


def vitest_summary():
    log = (out / 'vitest.log').read_text() if (out / 'vitest.log').exists() else ''
    m = re.search(r'Tests\s+(?:(\d+) failed \| )?(\d+) passed(?: \((\d+)\))?', log)
    if not m:
        return {'parsed': False}
    return {'parsed': True, 'failed': int(m.group(1) or 0), 'passed': int(m.group(2))}


def rubocop_summary():
    f = out / 'rubocop.json'
    if not f.exists():
        return {'parsed': False}
    d = json.loads(f.read_text())
    return {'parsed': True,
            'offenses': d['summary']['offense_count'],
            'files_inspected': d['summary']['inspected_file_count']}


def diff_summary():
    stat = out / 'changes.stat'
    if not stat.exists():
        return {'files_changed': 0, 'insertions': 0, 'deletions': 0, 'files': []}
    lines = stat.read_text().strip().splitlines()
    last = lines[-1] if lines else ''
    def grab(word):
        m = re.search(rf'(\d+) {word}', last)
        return int(m.group(1)) if m else 0
    files = [l.split('|')[0].strip() for l in lines[:-1] if '|' in l]
    return {'files_changed': grab('files? changed'),
            'insertions': grab(r'insertions?\(\+\)'),
            'deletions': grab(r'deletions?\(-\)'),
            'files': files}


metrics = {
    'run_id': os.environ['RUN_ID'],
    'agent': os.environ['AGENT'],
    'base_sha': os.environ['BASE_SHA'],
    'recorded_at': datetime.datetime.now(datetime.timezone.utc).isoformat(),
    'suites': {
        'rspec': {**status('rspec'), **rspec_summary()},
        'vitest': {**status('vitest'), **vitest_summary()},
        'eslint': status('eslint'),
        'rubocop': {**status('rubocop'), **rubocop_summary()},
    },
    'diff': diff_summary(),
}

(out / 'metrics.json').write_text(json.dumps(metrics, indent=2) + '\n')

r = metrics['suites']['rspec']
print()
print(f"run {metrics['run_id']} ({metrics['agent']})")
if r.get('parsed'):
    verdict = 'BASELINE CLEAN' if r['matches_baseline'] else 'DEVIATES FROM BASELINE'
    print(f"  rspec   {r['examples']} examples, {r['failures']} failures -> {verdict}")
    for f in r['unexpected_failures']:
        print(f"            + unexpected: {f}")
    for f in r['baseline_failures_missing']:
        print(f"            - known failure now passing: {f}")
else:
    print('  rspec   DID NOT PRODUCE JSON (see rspec.log)')
d = metrics['diff']
print(f"  diff    {d['files_changed']} files, +{d['insertions']}/-{d['deletions']}")
