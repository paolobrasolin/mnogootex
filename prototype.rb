#!/usr/bin/env ruby
# coding: utf-8

require 'tmpdir'
require 'fileutils'
require 'open3'

require 'colorize'

target = ARGV[0]

main_path = File.expand_path(target)
main_basename = File.basename main_path
main_dirname = File.dirname main_path

raise "File non esiste." unless File.exist? main_path

@documentclasses = [
  'book',
  'article',
  'scrartcl',
  'scrbook'
]

$jobs = []
$threads = []
$draw_threads = []

$threads = []

# $anim = '▁▂▃▄▅▆▇█▇▆▅▄▃▁'.freeze
$anim = '⣾⣽⣻⢿⡿⣟⣯⣷'.freeze

STDOUT.sync = true

def draw_status
  icons = $jobs.map do |j|
    icon = $anim[j.ticks % $anim.length]
    case j.thread.status
    when 'sleep', 'run', 'aborting'
      icon.yellow
    when false, nil # exited (normally or w/ error)
      j.success? ? icon.green : icon.red
    end
  end
  print '  Jobs: ' + icons.join + "\r"
end

class Job
  attr_reader :thread, :stdout_stderr, :log, :ticks, :cls

  def initialize(cls:, target:)
    @main_path = File.expand_path target
    @main_basename = File.basename @main_path
    @main_dirname = File.dirname @main_path
    raise "File non esiste." unless File.exist? @main_path

    @cls = cls
    @log = []
    @ticks = 0
  end

  def success?
    @thread.value.exitstatus == 0
  end

  def setup
    @tmp_dirname = Dir.mktmpdir ['mnogootex-']

    FileUtils.cp_r File.join(@main_dirname, '.'), @tmp_dirname

    @path = File.join @tmp_dirname, @main_basename

    code = File.read @path
    replace = code.sub /\\documentclass(\[.*?\])?{.*?}/,
                       "\\documentclass{#{@cls}}"

    File.open @path, "w" do |file|
      file.puts replace
    end
  end

  def run
    _, @stdout_stderr, @thread = Open3.popen2e(
      "texfot",
      "pdflatex",
      # "latexmk",
      # "-pdf",
      "--shell-escape", # TODO: remove me!
      "--interaction=nonstopmode",
      @main_basename,
      chdir: @tmp_dirname
    )
  end

  def tick_thread
    Thread.new do
      # 50ms polling cycle
      until (line = @stdout_stderr.gets).nil? do
        sleep 0.05
        @log << line
        @ticks += 1
        draw_status
        break unless @thread.alive?
      end
      # end of life treatment
      lines = @stdout_stderr.read.lines
      @log.concat lines
      @ticks += lines.length
      draw_status
    end
  end
end

draw_status

@documentclasses.each_with_index do |cls, index|
  job = Job.new cls: cls, target: main_path
  job.setup
  job.run

  $jobs << job

  $draw_threads << job.tick_thread
  $threads << job.thread
end

$threads.map(&:join)
$draw_threads.map(&:join)

puts


puts '  Details:'
$jobs.each do |job|
  if job.success?
    puts '    ' + "✔".green + ' ' + File.basename(job.cls)
  else
    puts '    ' + "✘".red + ' ' + File.basename(job.cls)
    puts job.log[2..-2].join.gsub(/^/,' '*6).chomp.red
  end
end

# puts $threads.map(&:status).join
# puts $threads.map(&:value).map(&:exitstatus).join
# puts $jobs.map(&:log)


