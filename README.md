# Credence API

API to store and retrieve confidential development files (configuration, credentials)

## Routes

All routes return Json

- GET  `/`: Root route shows if Web API is running
- GET  `api/v1/accounts/[username]`: Get account details
- POST  `api/v1/accounts`: Create a new acounts
- GET  `api/v1/projects/[proj_id]/documents/[doc_id]`: Get a document
- GET  `api/v1/projects/[proj_id]/documents`: Get list of documents for project
- POST `api/v1/projects/[proj_id]/documents`: Upload document for a project
- GET  `api/v1/projects/[proj_]`: Get information about a project
- GET  `api/v1/projects`: Get list of all projects
- POST `api/v1/projects`: Create new project

## Install

Install this API by cloning the *relevant branch* and use bundler to install specified gems from `Gemfile.lock`:

```shell
bundle install
```

Setup development database once:

```shell
rake db:migrate
```

## Test

Setup test database once:

```shell
RACK_ENV=test rake db:migrate
```

Run the test specification script in `Rakefile`:

```shell
rake spec
```

## Develop/Debug

Add fake data to the development database to work on this project:

```bash
rake db:seed
```

## Execute

Launch the API using:

```shell
rake run:dev
```

## Release check

Before submitting pull requests, please check if specs, style, and dependency audits pass (will need to be online to update dependency database):

```shell
rake release?
```
