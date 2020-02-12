# -*- coding: utf-8 -*-
$:.unshift(File.expand_path('../lib', __FILE__))

# Maintain your gem's version:
require "hammer_cli_foreman_tasks/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "hammer_cli_foreman_tasks"
  s.version     = HammerCLIForemanTasks.version
  s.authors     = ["Ivan Nečas"]
  s.license     = "GPL-3.0"
  s.email       = ["inecas@redhat.com"]
  s.homepage    = "https://github.com/theforeman/hammer-cli-foreman-tasks"
  s.summary     = "Foreman CLI plugin for showing tasks information for resoruces and users"
  s.description = <<DESC
Contains the code for showing of the tasks (results and progress) in the Hammer CLI.
DESC

  s.files = Dir["{lib,config,locale}/**/*", "LICENSE", "README.md"]
  s.require_paths = ["lib"]

  s.add_dependency "powerbar", ">= 1.0.11", "< 3.0"
  s.add_dependency "hammer_cli_foreman", "> 0.1.1", "< 3.0.0"
end
