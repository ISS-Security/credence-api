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

# Database
gem 'hirb'
gem 'sequel'
group :development, :test do
  gem 'sequel-seed'
  gem 'sqlite3'
end

# Security
gem 'bundler-audit'
gem 'rbnacl', '~>6.0'

# Testing
group :test do
  gem 'minitest'
  gem 'minitest-rg'
end

# Development
group :development do
  gem 'rubocop'
  gem 'rubocop-performance'
end

group :development, :test do
  gem 'rack-test'
  gem 'rerun'
end
