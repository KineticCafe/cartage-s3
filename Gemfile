# frozen_string_literal: true

# NOTE: This file is not the canonical source of dependencies. Edit the
# Rakefile, instead.

source 'https://rubygems.org/'

# Specify your gem's dependencies in cartage-bundler.gemspec
gemspec

group :local_development do
  gem 'cartage', path: '../cartage'

  gem 'byebug', platforms: :mri
  gem 'pry'
end if ENV['LOCAL_DEV']
