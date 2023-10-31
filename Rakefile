require 'rake/testtask'
require 'bundler/gem_tasks'
require "hammer_cli_foreman_tasks/version"
require "hammer_cli_foreman_tasks/i18n"
require "hammer_cli/i18n/find_task"
HammerCLI::I18n::FindTask.define(HammerCLIForemanTasks::I18n::LocaleDomain.new, HammerCLIForemanTasks.version.to_s)
Bundler::GemHelper.install_tasks

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end
