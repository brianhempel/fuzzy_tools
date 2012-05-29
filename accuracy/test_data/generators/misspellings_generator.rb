require File.expand_path('../accuracy_test_generator', __FILE__)

class MisspellingsGenerator < AccuracyTestGenerator
  # interesting stats
  #          first letter is diff in 135
  #         second letter is diff in 397
  #          third letter is diff in 918
  #         fourth letter is diff in 1615
  #          fifth letter is diff in 1945
  #
  #  fifth to last letter is diff in 1918
  # fourth to last letter is diff in 1543
  #  third to last letter is diff in 1177
  # second to last letter is diff in 705
  #           last letter is diff in 295
  #
  # (total is 4426)

  MisspellingPair = Struct.new(:wrong, :right)

  MISSPELLINGS_FILE = SOURCES_DIRECTORY + "/misspellings/misspellings.txt"

  def generate
    write_csv("misspellings.csv") do |csv|
      misspelling_pairs_unique_misspellings.group_by(&:right).each do |right, misspelling_pairs|
        csv << [right, misspelling_pairs.map(&:wrong).join('|')]
      end
    end
  end

  def all_misspelling_pairs
    all_pairs = []

    File.open(MISSPELLINGS_FILE).each do |line|
      next if line =~ /^\s*#|^\s*$/ # blank or comment

      wrong, *rights = line.split(/\t|\s*,\s+/).map(&:strip)

      all_pairs += rights.map { |right| MisspellingPair.new(wrong, right) }
    end

    all_pairs
  end

  def misspelling_pairs_unique_misspellings
    [].tap do |unique_misspellings|
      all_misspelling_pairs.group_by(&:wrong).each do |wrong, misspelling_pairs|
        unique_misspellings << misspelling_pairs[0] if misspelling_pairs.size == 1
      end
    end
  end
end