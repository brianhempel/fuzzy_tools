require 'set'
require File.expand_path('../accuracy_test_generator', __FILE__)

class DblpGenerator < AccuracyTestGenerator
  FILE = SOURCES_DIRECTORY + "/hpi_uni_potsdam_de/dblp/DBLP10K.csv"

  def raw_lines
    File.read(FILE).lines.map(&:chomp)
  end

  def raw_name_pairs
    raw_lines.map do |line|
      line.split(";", 5)
    end.select do |same_person, same_name, name1, name2, stuff|
      same_person == "t" && same_name == "f"
    end.map do |same_person, same_name, name1, name2, stuff|
      [name1, name2].to_set
    end.uniq.map(&:to_a).map(&:sort).sort
  end

  def generate
    write_csv("dblp_names.csv") do |csv|
      names_used = Set.new
      raw_name_pairs.each do |pair|
        name1, name2 = pair
        next if names_used.include?(name1)
        next if names_used.include?(name2)
        csv << [name1, name2]
        names_used << name1
        names_used << name2
      end
    end
  end
end
