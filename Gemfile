source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'

gem 'activerecord-import'
gem 'rails', '~> 5.2.3'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 3.11'
gem 'bootsnap', '>= 1.1.0', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'pry-rails'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'addressable', '~> 2.8', require: false
  gem 'bullet'
  gem 'diffy', require: false
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'meta_request'
  gem 'memory_profiler'
  gem 'rack-mini-profiler', require: ['enable_rails_patches', 'rack-mini-profiler']
  gem 'ruby-progressbar'
  gem 'ruby-prof'
  gem 'rubocop'
  gem 'stackprof'
end

group :test do
  gem 'rspec-benchmark'
  gem 'rspec-sqlimit'
  gem 'rspec-rails', '~> 4.1.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
