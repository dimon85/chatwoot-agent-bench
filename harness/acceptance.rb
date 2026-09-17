# Acceptance check for the prompt's three API requirements.
#
# Run with: RAILS_ENV=test bundle exec rails runner <this file>
# It lives in the harness, not the worktree, so it never appears in the agent's diff.
#
# The agent writes its own specs, which means the suite alone cannot tell us whether
# the feature works — the defendant is grading itself. This drives the real Rack stack
# through ActionDispatch::Integration, so it exercises routing, strong params, the
# model and the serializer exactly as a client would, without booting a server.

require 'json'

FIELD = 'preferred_language'
result = { field: FIELD, checks: {}, ok: false, error: nil }

begin
  unless Contact.column_names.include?(FIELD)
    raise "column #{FIELD} does not exist on contacts"
  end
  result[:checks][:column_exists] = true

  account = Account.create!(name: "acceptance-#{SecureRandom.hex(4)}")
  user = User.new(name: 'Acceptance', email: "acceptance-#{SecureRandom.hex(4)}@example.com",
                  password: 'Password1!', type: 'SuperAdmin')
  user.skip_confirmation!
  user.save!
  AccountUser.create!(account_id: account.id, user_id: user.id, role: :administrator)

  session = ActionDispatch::Integration::Session.new(Rails.application)
  headers = { 'api_access_token' => user.access_token.token, 'CONTENT_TYPE' => 'application/json' }
  base = "/api/v1/accounts/#{account.id}/contacts"

  # 1. settable on create
  session.post base, params: { name: 'Acceptance Contact', FIELD => 'uk' }.to_json, headers: headers
  raise "create returned #{session.response.status}" unless session.response.status.between?(200, 299)
  created = JSON.parse(session.response.body)
  payload = created['payload'].is_a?(Hash) ? (created['payload']['contact'] || created['payload']) : created
  contact_id = payload['id']
  result[:checks][:settable_on_create] = payload[FIELD] == 'uk'

  # 2. persisted in the database, not just echoed back
  result[:checks][:persisted] = Contact.find(contact_id).public_send(FIELD) == 'uk'

  # 3. updatable
  session.patch "#{base}/#{contact_id}", params: { FIELD => 'de' }.to_json, headers: headers
  raise "update returned #{session.response.status}" unless session.response.status.between?(200, 299)
  result[:checks][:updatable] = Contact.find(contact_id).public_send(FIELD) == 'de'

  # 4. returned in a read response
  session.get "#{base}/#{contact_id}", headers: headers
  raise "show returned #{session.response.status}" unless session.response.status.between?(200, 299)
  shown = JSON.parse(session.response.body)
  shown_payload = shown['payload'].is_a?(Hash) ? (shown['payload']['contact'] || shown['payload']) : shown
  result[:checks][:returned_in_response] = shown_payload.key?(FIELD)
  result[:checks][:returned_value_correct] = shown_payload[FIELD] == 'de'

  result[:ok] = result[:checks].values.all?
rescue StandardError => e
  result[:error] = "#{e.class}: #{e.message}"
end

puts JSON.pretty_generate(result)
