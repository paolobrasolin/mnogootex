


require 'thread'


ANIM_FRAMES = "⣾⣽⣻⢿⡿⣟⣯⣷"

queue = Queue.new
threads = []

# Start 2 threads to pop work off of the queue and print it, then sleep 3 seconds for effect
120.times do |n|
  threads << Thread.new do
    rand(1..100).times do
      queue.push n
      sleep rand*0.1
    end
    4.times { queue.push n }
  end
end

stata = [0] * 120

th = Thread.new do
  while threads.any?(&:status) do
    qi = queue.pop
    stata[qi] += 1
    print "  "
    print stata.map { |s| ANIM_FRAMES[s % ANIM_FRAMES.length] }.join
    print "\r"
  end
end

th.join
puts
