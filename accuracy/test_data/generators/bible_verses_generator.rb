require File.expand_path('../accuracy_test_generator', __FILE__)

class BibleVersesGenerator < AccuracyTestGenerator

  KJV_FILE = File.expand_path('../../sources/bible/KJV1611.txt', __FILE__)
  ASV_FILE = File.expand_path('../../sources/bible/asv-usfx.xml', __FILE__)
  
  BOOKS            = ["Genesis", "Exodus", "Leviticus", "Numbers", "Deuteronomy", "Joshua", "Judges", "Ruth", "1 Samuel", "2 Samuel", "1 Kings", "2 Kings", "1 Chronicles", "2 Chronicles", "Ezra", "Nehemiah", "Esther", "Job", "Psalms", "Proverbs", "Ecclesiastes", "Song of Songs", "Isaiah", "Jeremiah", "Lamentations", "Ezekiel", "Daniel", "Hosea", "Joel", "Amos", "Obadiah", "Jonah", "Micah", "Nahum", "Habakkuk", "Zephaniah", "Haggai", "Zechariah", "Malachi", "Matthew", "Mark", "Luke", "John", "Acts", "Romans", "1 Corinthians", "2 Corinthians", "Galatians", "Ephesians", "Philippians", "Colossians", "1 Thessalonians", "2 Thessalonians", "1 Timothy", "2 Timothy", "Titus", "Philemon", "Hebrews", "James", "1 Peter", "2 Peter", "1 John", "2 John", "3 John", "Jude", "Revelation"]
  KJV_BOOKS_ABBREV = ["Ge", "Ex", "Le", "Nu", "De", "Jos", "Jg", "Ru", "1Sa", "2Sa", "1Ki", "2Ki", "1Ch", "2Ch", "Ezr", "Ne", "Es", "Job", "Ps", "Pr", "Ec", "Song", "Isa", "Jer", "La", "Eze", "Da", "Ho", "Joe", "Am", "Ob", "Jon", "Mic", "Na", "Hab", "Zep", "Hag", "Zec", "Mal", "Mt", "Mr", "Lu", "Joh", "Ac", "Ro", "1Co", "2Co", "Ga", "Eph", "Php", "Col", "1Th", "2Th", "1Ti", "2Ti", "Tit", "Phm", "Heb", "Jas", "1Pe", "2Pe", "1Jo", "2Jo", "3Jo", "Jude", "Re"]
  ASV_BOOKS_ABBREV = ["GEN", "EXO", "LEV", "NUM", "DEU", "JOS", "JDG", "RUT", "1SA", "2SA", "1KI", "2KI", "1CH", "2CH", "EZR", "NEH", "EST", "JOB", "PSA", "PRO", "ECC", "SNG", "ISA", "JER", "LAM", "EZK", "DAN", "HOS", "JOL", "AMO", "OBA", "JON", "MIC", "NAM", "HAB", "ZEP", "HAG", "ZEC", "MAL", "MAT", "MRK", "LUK", "JHN", "ACT", "ROM", "1CO", "2CO", "GAL", "EPH", "PHP", "COL", "1TH", "2TH", "1TI", "2TI", "TIT", "PHM", "HEB", "JAS", "1PE", "2PE", "1JN", "2JN", "3JN", "JUD", "REV"]

  class Verse
    attr_accessor :book, :chapter_no, :verse_no
    attr_accessor :kjv, :asv
    
    def initialize(options)
      @book       = options[:book]
      @chapter_no = options[:chapter_no]
      @verse_no   = options[:verse_no]
      @kjv        = options[:kjv]
      @asv        = options[:asv]
    end
    
    def kjv_clean
      # Why [art] thou -> Why art thou
      @kjv.gsub(/\[([^\]]*)\]/, '\1').strip
    end

    def asv_clean
      # have ye <add>another</add> brother? -> have ye another brother?
      @asv.gsub(/<[^>]*>/, '').strip
    end
  end

  attr_accessor :verses

  def initialize
    @verses = {}
    load_kjv
    load_asv
  end

  def generate
    %w(Daniel Jude).each do |book_name|
      write_csv("bible_verses_#{book_name.downcase}_kjv.csv") do |csv|
        verses[book_name].each do |chapter_no, verses|
          verses.each do |verse_no, verse|
            csv << [verse.kjv, verse.asv] if verse.asv && verse.kjv
          end
        end
      end
    end
  end

  def all_verses_with_both_translations
    result = []
    
    BOOKS.each do |book_name|
      chapters = verses[book_name]
      chapters.each do |chapter_no, verses|
        verses.each do |verse_no, verse|
          result << verse if verse.asv && verse.kjv
        end
      end
    end
        
    result
  end
  
  def load_kjv
    File.open(KJV_FILE).each do |line|
      next if line =~ /^\s*#/
      
      line =~ /^(\w+)\s+(\d+):(\d+)\s+(.+)/

      book_abbrev = $1
      chapter_no  = $2.to_i
      verse_no    = $3.to_i
      text        = $4
      
      book = BOOKS[KJV_BOOKS_ABBREV.index { |b| b =~ /^#{book_abbrev}/ }]
      throw "ahh! unknown book #{book_abbrev}" unless book
      
      self.verses[book]                       ||= {}
      self.verses[book][chapter_no]           ||= {}
      self.verses[book][chapter_no][verse_no] ||= Verse.new(:book => book, :chapter_no => chapter_no, :verse_no => verse_no)
      self.verses[book][chapter_no][verse_no].kjv = text
    end
  end
  
  def load_asv
    book       = nil
    chapter_no = nil
    
    File.open(ASV_FILE).each do |line|
      next if line =~ /^\s*#/
      
      line =~ /^<(\w+) id="(\w+)"\s*\/?>\s*(.*)/
      
      case $1
      when "book"
        book_abbrev = $2
        book = BOOKS[ASV_BOOKS_ABBREV.index { |b| b =~ /^#{book_abbrev}/ }]
        throw "ahh! unknown book #{book_abbrev}" unless book
      when "c"
        chapter_no = $2.to_i
      when "v"
        verse_no    = $2.to_i
        text        = $3

        self.verses[book]                       ||= {}
        self.verses[book][chapter_no]           ||= {}
        self.verses[book][chapter_no][verse_no] ||= Verse.new(:book => book, :chapter_no => chapter_no, :verse_no => verse_no)
        self.verses[book][chapter_no][verse_no].asv = text
      end
    end
  end
  
end