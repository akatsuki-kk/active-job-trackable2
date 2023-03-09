# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'activejob/trackable2/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = 'activejob-trackable2'
  spec.version     = ActiveJob::Trackable2::VERSION
  spec.authors     = ['Akatsuki-kk']
  spec.email       = ['ktokzki.bis@gmail.com']
  spec.homepage    = 'https://github.com/akatsuki-kk/active-job-trackable2'
  spec.summary     = 'Active-job-trackable(https://github.com/ignatiusreza/activejob-trackable) for Rails 6.0 or later'
  spec.description = 'Get more control into your jobs with the ability to track (debounce, throttle) jobs'
  spec.license     = 'MIT'

  spec.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  spec.add_dependency 'rails', '~> 6.0'

  spec.add_development_dependency 'minitest-ci'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-performance'
  spec.add_development_dependency 'sqlite3', '~> 1.6.1'
end
