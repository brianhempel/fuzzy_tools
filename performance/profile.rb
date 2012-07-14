require 'csv'

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'fuzzy'


TEST_FILE_PATH = File.expand_path("../query_tests/bible_verses_daniel_kjv.csv", __FILE__)

QueryTest = Struct.new(:expected, :query)


@query_tests = []

CSV.read(TEST_FILE_PATH).each do |row|
  next if row[1] == "queries"

  target, query = row[0], row[1]

  @query_tests << QueryTest.new(target, query)
end

targets = @query_tests.map(&:expected)

ENV['CPUPROFILE_REALTIME']      = "1"
ENV['CPUPROFILE_FREQUENCY=500'] = "200" # default is 100
require 'perftools'
PerfTools::CpuProfiler.start("/tmp/fuzzy_ruby_profile")
at_exit do
  PerfTools::CpuProfiler.stop
  puts `pprof.rb --text /tmp/fuzzy_ruby_profile`
end

index = targets.fuzzy_index

passed = 0

actual_tests = @query_tests.take(400)
actual_tests.each do |test|
  expected, query = test.expected, test.query

  if expected == index.find(query)
    print "."
    STDOUT.flush
    passed += 1
  else
    print "F"
    STDOUT.flush
  end
end

puts
puts "%.2f%% passed (should be 100%% for reference TF IDF)" % [passed*100.0 / actual_tests.size]
puts
