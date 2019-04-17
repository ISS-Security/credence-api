# frozen_string_literal: true

# Demo in `rake console`
## Working attack (on 1_demo_db_vulnerabilities branch)
Credence::Project.create(
  name: 'Future Project',
  repo_url: 'http://github.com/fakeproject',
  created_at: Time.new('1900-01-01')
)

req_header = { 'CONTENT_TYPE' => 'application/json' }
req_body = { name: 'Bad Date', created_at: '1900-01-01' }.to_json
post '/api/v1/projects', req_body, req_header

# primary key target
Credence::Project.create(id: 55, name: 'Malicious Project')

# web attack sample on primary key:
req_header = { 'CONTENT_TYPE' => 'application/json' }
req_body = { id: 55, name: 'Malicious Project' }.to_json
post '/api/v1/projects/', req_body, req_header
last_response.status
last_response.body

## Practical Mass Assignment restriction (on 2_db_hardening branch)
Credence::Project.create(
  name: 'Future Project',
  repo_url: 'http://github.com/fakeproject',
  created_at: Time.new('1900-01-01')
)
# => Sequel::MassAssignmentRestriction: created_at is a restricted column
