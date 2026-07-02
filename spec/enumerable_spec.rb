require 'spec_helper'
require 'set'

describe Enumerable do
  before :each do
    @till_we_have_faces = Book.new("Till We Have Faces", "C.S. Lewis" )
    @ecclesiastes       = Book.new("Ecclesiastes",       "The Teacher")
    @the_prodigal_god   = Book.new("The Prodigal God",   "Tim Keller" )

    @books = [
      @till_we_have_faces,
      @ecclesiastes,
      @the_prodigal_god
    ].each
  end

  describe "#fuzzy_find" do
    it "works with simple query syntax" do
      @books.fuzzy_find("the").should == @ecclesiastes
    end

    it "works with :attribute => query syntax" do
      @books.fuzzy_find(:title => "the").should == @the_prodigal_god
    end

    context "passes :tokenizer through to the index" do
      before(:each) { @letter_count_tokenizer = lambda { |str| str.size.to_s } }

      it "passes :tokenizer through to the index with simple query syntax" do
        FuzzyTools::TfIdfIndex.should_receive(:new).with({ :source => @books, :tokenizer => @letter_count_tokenizer })
        begin
          @books.fuzzy_find("the", :tokenizer => @letter_count_tokenizer)
        rescue
        end
      end

      it "passes :tokenizer through to the index with :attribute => query syntax" do
        FuzzyTools::TfIdfIndex.should_receive(:new).with({ :source => @books, :tokenizer => @letter_count_tokenizer, :attribute => :title })
        begin
          @books.fuzzy_find(:title => "the", :tokenizer => @letter_count_tokenizer)
        rescue
        end
      end
    end
  end

  describe "#fuzzy_find_all" do
    it "works with simple query syntax" do
      @books.fuzzy_find_all("the").should == [@ecclesiastes, @the_prodigal_god, @till_we_have_faces]
    end

    it "works with :attribute => query syntax" do
      @books.fuzzy_find_all(:title => "the").should == [@the_prodigal_god, @till_we_have_faces]
    end

    context "passes :tokenizer through to the index" do
      before(:each) { @letter_count_tokenizer = lambda { |str| str.size.to_s } }

      it "passes :tokenizer through to the index with simple query syntax" do
        FuzzyTools::TfIdfIndex.should_receive(:new).with({ :source => @books, :tokenizer => @letter_count_tokenizer })
        begin
          @books.fuzzy_find_all("the", :tokenizer => @letter_count_tokenizer)
        rescue
        end
      end

      it "passes :tokenizer through to the index with :attribute => query syntax" do
        FuzzyTools::TfIdfIndex.should_receive(:new).with({ :source => @books, :tokenizer => @letter_count_tokenizer, :attribute => :title })
        begin
          @books.fuzzy_find_all(:title => "the", :tokenizer => @letter_count_tokenizer)
        rescue
        end
      end
    end
  end

  describe "#fuzzy_find_all_with_scores" do
    it "works with simple query syntax" do
      results = @books.fuzzy_find_all_with_scores("the")

      results.map(&:first).should == [@ecclesiastes, @the_prodigal_god, @till_we_have_faces]
      results.sort_by { |doc, score| -score }.should == results
    end

    it "works with :attribute => query syntax" do
      results = @books.fuzzy_find_all_with_scores(:title => "the")

      results.map(&:first).should == [@the_prodigal_god, @till_we_have_faces]
      results.sort_by { |doc, score| -score }.should == results
    end

    context "passes :tokenizer through to the index" do
      before(:each) { @letter_count_tokenizer = lambda { |str| str.size.to_s } }

      it "passes :tokenizer through to the index with simple query syntax" do
        FuzzyTools::TfIdfIndex.should_receive(:new).with({ :source => @books, :tokenizer => @letter_count_tokenizer })
        begin
          @books.fuzzy_find_all_with_scores("the", :tokenizer => @letter_count_tokenizer)
        rescue
        end
      end

      it "passes :tokenizer through to the index with :attribute => query syntax" do
        FuzzyTools::TfIdfIndex.should_receive(:new).with({ :source => @books, :tokenizer => @letter_count_tokenizer, :attribute => :title })
        begin
          @books.fuzzy_find_all_with_scores(:title => "the", :tokenizer => @letter_count_tokenizer)
        rescue
        end
      end
    end
  end

  describe "#fuzzy_index" do
    it "returns an TfIdfIndex" do
      @books.fuzzy_index.class.should == FuzzyTools::TfIdfIndex
    end

    it "passes options along to the index" do
      letter_count_tokenizer = lambda { |str| str.size.to_s }
      FuzzyTools::TfIdfIndex.should_receive(:new).with({ :source => @books, :tokenizer => letter_count_tokenizer, :attribute => :title })
      @books.fuzzy_index(:attribute => :title, :tokenizer => letter_count_tokenizer)
    end
  end
end