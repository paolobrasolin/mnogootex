# frozen_string_literal: true

require 'rspec/core/rake_task'

namespace :spec do
  desc 'run RSpec'
  RSpec::Core::RakeTask.new(:rspec)

  desc 'run SimpleCov'
  task :simplecov do
    ENV['COVERAGE'] = 'true'
    Rake::Task['spec:rspec'].invoke
  end

  desc 'run Mutant'
  task :mutant do
    arguments = %w[
      bundle exec mutant
      --use rspec
      --zombie
    ]

    arguments.concat(%w[-- Mnogootex::Configuration])

    Kernel.system(*arguments) || raise('Mutant task is not successful')
  end
end
