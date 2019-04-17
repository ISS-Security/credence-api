# frozen_string_literal: true

# for running in `rake console` (pry)
cd Credence

proj = Project.create(name: 'Demo Project')
conf = proj.add_document(
  filename: 'app.yml',
  description: 'Secret credentials file',
  content: "---\ndevelopment:\n  DB_KEY: 'n6UUYIQMn4rC9L8BlNBgeW1G6'"
)

app.DB[:documents].all

conf.description_secure
conf.description

conf.content_secure
conf.content
