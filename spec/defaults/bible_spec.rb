require 'spec_helper'

describe Array do
  describe "#fuzzy" do
    context "defaults" do
            
      it "should match the KJV to ASV" do
        # @bible = Bible.new
      end
      
      Bible::BOOKS.each_index do |i|
        book       = Bible::BOOKS[i]
        kjv_abbrev = Bible::KJV_BOOKS_ABBREV[i]
        asv_abbrev = Bible::ASV_BOOKS_ABBREV[i]

        it "should find '#{book}' in Bible::BOOKS when queried with '#{kjv_abbrev}' " do
          Bible::BOOKS.dup.fuzzy(kjv_abbrev).should == book
        end

        it "should find '#{book}' in Bible::BOOKS when queried with '#{asv_abbrev}' " do
          Bible::BOOKS.dup.fuzzy(asv_abbrev).should == book
        end

        it "should find '#{kjv_abbrev}' in Bible::KJV_BOOKS_ABBREV when queried with '#{book}' " do
          Bible::KJV_BOOKS_ABBREV.dup.fuzzy(book).should == kjv_abbrev
        end

        it "should find '#{kjv_abbrev}' in Bible::KJV_BOOKS_ABBREV when queried with '#{asv_abbrev}' " do
          Bible::KJV_BOOKS_ABBREV.dup.fuzzy(asv_abbrev).should == kjv_abbrev
        end

        it "should find '#{asv_abbrev}' in Bible::ASV_BOOKS_ABBREV when queried with '#{book}' " do
          Bible::ASV_BOOKS_ABBREV.dup.fuzzy(book).should == asv_abbrev
        end

        it "should find '#{asv_abbrev}' in Bible::ASV_BOOKS_ABBREV when queried with '#{kjv_abbrev}' " do
          Bible::ASV_BOOKS_ABBREV.dup.fuzzy(kjv_abbrev).should == asv_abbrev
        end
      end

    end
  end
end