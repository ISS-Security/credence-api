# frozen_string_literal: true

source 'https://rubygems.org'
ruby '2.6.2'

# Web API
gem 'json'
gem 'puma', '~>3.11'
gem 'rack', '>= 2.0.6'
gem 'roda', '~>3.6'

# Configuration
gem 'econfig'
gem 'rake'

# Debugging
gem 'pry'
gem 'rack-test'

# Database
gem 'hirb'
gem 'sequel'

# External Services
gem 'http'

group :development, :test do
  gem 'sequel-seed'
  gem 'sqlite3'
end

group :production do
  gem 'pg'
end

# Security
gem 'bundler-audit'
gem 'rbnacl', '~>6.0'

# Testing
group :test do
  gem 'minitest'
  gem 'minitest-rg'
  gem 'simplecov'
  gem 'webmock'
end

# Development
group :development do
  gem 'rubocop'
  gem 'rubocop-performance'
end

group :development, :test do
  gem 'rerun'
end
