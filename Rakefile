require 'bundler'
Bundler::GemHelper.install_tasks

Dir[File.expand_path('../accuracy/**/*.task', __FILE__)].each { |f| load f }
Dir[File.expand_path('../performance/**/*.task', __FILE__)].each { |f| load f }
