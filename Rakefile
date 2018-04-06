# frozen_string_literal: true

require 'mutant'
require 'dry/inflector'

require 'rspec/core/rake_task'

namespace :spec do
  desc 'run RSpec'
  RSpec::Core::RakeTask.new(:rspec) do |task|
    task.rspec_opts = '--format documentation'
  end

  desc 'run SimpleCov'
  task :simplecov do
    ENV['COVERAGE'] = 'true'
    Rake::Task['spec:rspec'].invoke
  end

  desc 'run Mutant'
  task :mutant, [:subject] do |_, args|
    subjects = [args[:subject]].compact
    subjects << 'Mnogootex*' if subjects.empty?
    successful = ::Mutant::CLI.run(%w[--use rspec --fail-fast] + subjects)
    raise('Mutant task is not successful') unless successful
  end
end
