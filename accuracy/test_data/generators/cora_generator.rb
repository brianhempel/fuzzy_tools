require File.expand_path('../accuracy_test_generator', __FILE__)

# in the following paper, they used the whole line (key and all) and tokenized by word, so we'll use the whole line
# A comparison of string distance metrics for name-matching tasks, by W. W Cohen, P. Ravikumar, S. E Fienberg. In Proceedings of the IJCAI-2003 Workshop on Information Integration on the Web (IIWeb-03), 2003.

class CoraGenerator < AccuracyTestGenerator
  # key is the second column

  CORA_FILE = SOURCES_DIRECTORY + "/cora/cora.tsv"

  def generate
    write_csv("cora.csv") do |csv|
      key_to_lines.each do |key, lines|
        if lines.size > 1
          csv << [lines[0], lines[1..-1].join("|")]
        end
      end
    end
  end

  def key_to_lines
    key_to_lines = {}

    File.open(CORA_FILE).each do |line|
      next if line =~ /^\s*#|^\s*$/ # blank or comment

      unknown, key, citation = line.split(/\t/, 3)

      key_to_lines[key] ||= []
      key_to_lines[key] << line.chomp
    end

    key_to_lines
  end
end