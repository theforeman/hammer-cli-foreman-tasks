source 'https://rubygems.org'

gemspec

gem 'gettext', '>= 3.1.3', '< 4.0.0'
gem 'psych' # requiring psych to workaround issues with bundler 1.11.0, see https://github.com/bundler/bundler/issues/4149

group :test do
  gem 'ci_reporter', '>= 1.6.3', '< 2.0.0', :require => false
  gem 'minitest', '>= 5.1'
  gem 'minitest-spec-context'
  gem 'mocha'
  gem 'rake', '~> 13.1.0'
  gem 'simplecov'
  gem 'theforeman-rubocop', '~> 0.1.0'
end

# load local gemfile
['Gemfile.local.rb', 'Gemfile.local'].map do |file_name|
  local_gemfile = File.join(File.dirname(__FILE__), file_name)
  instance_eval(Bundler.read_file(local_gemfile)) if File.exist?(local_gemfile)
end
