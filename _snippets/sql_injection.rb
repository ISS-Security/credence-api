# frozen_string_literal: true

# Demonstration of SQL injection on 1-db_testing branch of ConfigShare API

## SETUP in bash
`rake db:drop`
`rake db:migrate`

## SETUP in Tux
# User creates a project and config files
real_proj = Credence::Project.create(name: 'Alice Project')
real_proj.add_document(filename: 'secrets.yml')

# Hacker creates a project and config files
hack_proj = Credence::Project.create(name: 'Eve Project')
hack_proj.add_document(filename: 'hacker_file.txt')

# SQL INJECTION DEMO
# Regular queries to the API will look like this:
get 'http://localhost:9292/api/v1/projects/2'
puts last_response.body

# Assume application code uses naked SQL queries!
proj_id = '2'
app.DB["SELECT * FROM projects WHERE id=#{proj_id}"].to_a

# Hacker is trying to steal project with id == 1
# SQL injection using API web route:
get 'http://localhost:9292/api/v1/projects/2%20or%20id%3D1'
puts last_response.body

proj_id = '2 or id=1'
app.DB["SELECT * FROM projects WHERE id=#{proj_id}"].to_a

# Note: validation of parameter might even pass:
id = '2%20or%20id%3D1'
id.to_i == 2 ? puts('safe') : puts('warning')

# LITERALIZATION
Credence::Project.where(id: 2).all
Credence::Project.where(id: '2 or id = 1').all

# QUERY PARAMETERIZATION: Bound Statements (in code)
projects = Credence::Project.where(id: :$find_id)
projects.call(:select, find_id: 2)
