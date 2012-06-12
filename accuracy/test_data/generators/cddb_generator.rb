require 'set'
require 'rubygems'
require 'nokogiri'
require File.expand_path('../accuracy_test_generator', __FILE__)

class CddbGenerator < AccuracyTestGenerator

  ALL_ALBUMS_FILE = SOURCES_DIRECTORY + "/hpi_uni_potsdam_de/cddb/cddb_ID_nested_10000.xml"
  DUPLICATES_FILE = SOURCES_DIRECTORY + "/hpi_uni_potsdam_de/cddb/cddb_9763_dups.xml"

  def all_albums_nokogiri
    @all_albums_nokogiri     ||= Nokogiri.parse(File.read(ALL_ALBUMS_FILE))
  end

  def duplicates_nokogiri
    @all_duplicates_nokogiri ||= Nokogiri.parse(File.read(DUPLICATES_FILE))
  end

  def disc_id(disc)
    (disc.css('did').first || disc.css('cid').first).text.strip + "/" + disc.css('dtitle').first.text.strip
  end

  def duplicated_id_sets
    @duplicated_id_sets ||= begin
      pair_ids = duplicates_nokogiri.css('pair').map do |pair|
        pair.css('disc').map { |disc| disc_id(disc) }
      end
      sets = []
      pair_ids.each do |id1, id2|
        set1 = sets.find { |set| set.include?(id1) }
        set2 = sets.find { |set| set.include?(id2) }

        if !set1 && !set2
          sets << [id1, id2].to_set
        elsif set1 && set2
          if set1 != set2
            # merge
            sets.delete(set2)
            set2.each { |id| set1 << id }
          end
          set1 << id1
          set1 << id2
        elsif set1 && !set2
          set1 << id1
          set1 << id2
        elsif !set1 && set2
          set2 << id1
          set2 << id2
        end
      end
      sets
    end
  end

  def duplicate_id_to_id_set
    @duplicate_id_to_id_set ||= {}.tap do |duplicate_id_to_id_set|
      duplicated_id_sets.each do |set|
        set.each { |id| duplicate_id_to_id_set[id] = set }
      end
    end
  end

  def all_discs
    all_albums_nokogiri.css('disc')
  end

  def id_to_string_line
    @id_to_string_line ||= {}.tap do |id_to_string_line|
      all_discs.each do |disc|
        text                  = disc.text.gsub(/\s/, " ").gsub("|", "-")
        id                    = disc_id(disc)
        id_to_string_line[id] = text
      end
    end
  end

  def generate
    write_csv("cddb.csv") do |csv|
      used_ids = Set.new
      duplicated_id_sets.each do |set|
        dups             = set.to_a.map { |id| [id, id_to_string_line[id]] }
        nil_id, nil_line = dups.find { |id, text| !text }
        next if nil_id
        target_id, target  = dups.shift
        csv << [target, dups.map(&:last).join("|")]
        set.each { |id| used_ids << id }
      end
      # id_to_string_line.each do |id, line|
      #   csv << [line.gsub("|", "-"), ""] unless used_ids.include?(id)
      #   used_ids << id
      # end
    end
  end
end
