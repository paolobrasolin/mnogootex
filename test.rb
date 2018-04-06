# frozen_string_literal: true

require 'open3'

@stuff = []

_, @stream, @thread = Open3.popen2e('sleep 0.5; echo wot; sleep 0.5; echo lol; sleep 0.5')

@thread.join

th = Thread.new do
  until (line = @stream.gets).nil?
    @stuff << line
  end
end
th.join
puts th.exitstatus

puts "result: #{@stuff.inspect} #{@line_count}"
