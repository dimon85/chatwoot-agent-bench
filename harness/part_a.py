#!/usr/bin/env python3
"""Part A of the rubric: counting only, no judgement.

Run before any diff is read closely. Everything here is a fact that can be extracted
mechanically, so that the numbers cannot drift while a human forms an opinion.
"""
import json, pathlib, re, sys

BENCH = pathlib.Path.home() / 'chatwoot-agent-bench'

PARAM_ENTRY_POINTS = [
    'app/controllers/api/v1/accounts/contacts_controller.rb',
    'app/controllers/public/api/v1/inboxes/contacts_controller.rb',
    'app/controllers/api/v1/widget/contacts_controller.rb',
    'app/controllers/api/v1/widget/conversations_controller.rb',
]
SERIALIZERS = [
    'app/views/api/v1/models/_contact.json.jbuilder',
    'app/views/public/api/v1/models/_contact.json.jbuilder',
    'app/views/api/v1/accounts/search/_contact.json.jbuilder',
]
SWAGGER_DASH = [
    'swagger/definitions/resource/contact.yml',
    'swagger/definitions/resource/contact_detail.yml',
    'swagger/definitions/resource/contact_list_item.yml',
    'swagger/definitions/request/contact/create_payload.yml',
    'swagger/definitions/request/contact/update_payload.yml',
]
SWAGGER_PUBLIC = [
    'swagger/definitions/resource/public/contact.yml',
    'swagger/definitions/resource/public/contact_record.yml',
    'swagger/definitions/request/public/contact/create_update_payload.yml',
]
FORM_LEGACY = 'app/javascript/dashboard/routes/dashboard/conversation/contact/ContactForm.vue'
FORM_NEXT = 'app/javascript/dashboard/components-next/Contacts/ContactsForm/ContactsForm.vue'


def files_in(patch):
    return set(re.findall(r'^\+\+\+ b/(.+)$', patch, re.M))


def row(run):
    d = BENCH / 'runs' / run
    m = json.loads((d / 'metrics.json').read_text())
    files = files_in((d / 'changes.patch').read_text())
    gen = [f for f in files if f == 'swagger/swagger.json' or f.startswith('swagger/tag_groups/')]
    return {
        'run': run,
        'A1_migration': int(any(f.startswith('db/migrate/') for f in files)),
        'A2_schema': int('db/schema.rb' in files),
        'A3_annotation': int('app/models/contact.rb' in files),
        'A4_param_entry_points': f"{sum(f in files for f in PARAM_ENTRY_POINTS)}/4",
        'A5_serializers': f"{sum(f in files for f in SERIALIZERS)}/3",
        'A5b_swagger_dash': f"{sum(f in files for f in SWAGGER_DASH)}/5",
        'A5b_swagger_public': f"{sum(f in files for f in SWAGGER_PUBLIC)}/3",
        'A5c_swagger_generated': len(gen),
        'A7_form_legacy': int(FORM_LEGACY in files),
        'A7_form_next': int(FORM_NEXT in files),
        'A7b_i18n': int(any('i18n/locale/en/contact.json' in f for f in files)),
        'A7b_vue_total': sum(1 for f in files if f.startswith('app/javascript/')),
        'A8_spec_files': sum(1 for f in files if f.startswith('spec/')),
        'A10_files': m['diff']['files_changed'],
        'A10_ins': m['diff']['insertions'],
        'A10_del': m['diff']['deletions'],
        'A11_steps': m['agent_effort'].get('steps'),
        'A11_wall_s': m['agent_effort'].get('wall_s'),
        'A11_cache_read': m['agent_effort']['tokens']['cache_read'],
        'A11_output': m['agent_effort']['tokens']['output'],
        'A11b_harness_usd': m['agent_effort'].get('harness_reported_cost_usd'),
        'A12_instrument': int((d / 'INSTRUMENT_MODIFIED').exists()),
        'baseline_clean': int(bool(m['suites']['rspec'].get('matches_baseline'))),
        'acceptance_ok': int(bool(m.get('acceptance', {}).get('ok'))),
        'rubocop_offenses': m['suites']['rubocop'].get('offenses'),
        'window_utc': (m.get('run_window_utc') or {}).get('started_utc'),
    }


runs = sys.argv[1:] or ['a1', 'a2', 'a3', 'b1', 'b2', 'b3']
rows = [row(r) for r in runs if (BENCH / 'runs' / r / 'metrics.json').exists()]
out = BENCH / 'results' / 'part_a.json'
out.parent.mkdir(exist_ok=True)
out.write_text(json.dumps(rows, indent=2) + '\n')

keys = [k for k in rows[0] if k != 'run']
width = max(len(k) for k in keys) + 2
print(f"{'':{width}}" + ''.join(f'{r["run"]:>10}' for r in rows))
for k in keys:
    print(f'{k:{width}}' + ''.join(f'{str(r[k]):>10}' for r in rows))
print(f'\nwritten: {out}')
