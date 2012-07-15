require 'spec_helper'
require 'set'

describe Enumerable do
  before :each do
    @till_we_have_faces = Book.new("Till We Have Faces", "C.S. Lewis" )
    @ecclesiates        = Book.new("Ecclesiates",        "The Teacher")
    @the_prodigal_god   = Book.new("The Prodigal God",   "Tim Keller" )

    @books = [
      @till_we_have_faces,
      @ecclesiates,
      @the_prodigal_god
    ].each
  end

  describe "#fuzzy_find" do
    it "works with simple query syntax" do
      @books.fuzzy_find("the").should == @ecclesiates
    end

    it "works with :attribute => query syntax" do
      @books.fuzzy_find(:title => "the").should == @the_prodigal_god
    end

    context "passes :tokenizer through to the index" do
      before(:each) { @letter_count_tokenizer = lambda { |str| str.size.to_s } }

      it "passes :tokenizer through to the index with simple query syntax" do
        Fuzzy::TfIdfIndex.should_receive(:new).with(:source => @books, :tokenizer => @letter_count_tokenizer)
        begin
          @books.fuzzy_find("the", :tokenizer => @letter_count_tokenizer)
        rescue
        end
      end

      it "passes :tokenizer through to the index with :attribute => query syntax" do
        Fuzzy::TfIdfIndex.should_receive(:new).with(:source => @books, :tokenizer => @letter_count_tokenizer, :attribute => :title)
        begin
          @books.fuzzy_find(:title => "the", :tokenizer => @letter_count_tokenizer)
        rescue
        end
      end
    end
  end

  describe "#fuzzy_find_all" do
    it "works with simple query syntax" do
      @books.fuzzy_find_all("the").should == [@ecclesiates, @the_prodigal_god, @till_we_have_faces]
    end

    it "works with :attribute => query syntax" do
      @books.fuzzy_find_all(:title => "the").should == [@the_prodigal_god, @till_we_have_faces]
    end

    context "passes :tokenizer through to the index" do
      before(:each) { @letter_count_tokenizer = lambda { |str| str.size.to_s } }

      it "passes :tokenizer through to the index with simple query syntax" do
        Fuzzy::TfIdfIndex.should_receive(:new).with(:source => @books, :tokenizer => @letter_count_tokenizer)
        begin
          @books.fuzzy_find_all("the", :tokenizer => @letter_count_tokenizer)
        rescue
        end
      end

      it "passes :tokenizer through to the index with :attribute => query syntax" do
        Fuzzy::TfIdfIndex.should_receive(:new).with(:source => @books, :tokenizer => @letter_count_tokenizer, :attribute => :title)
        begin
          @books.fuzzy_find_all(:title => "the", :tokenizer => @letter_count_tokenizer)
        rescue
        end
      end
    end
  end

  describe "#fuzzy_index" do
    it "returns an TfIdfIndex" do
      @books.fuzzy_index.class.should == Fuzzy::TfIdfIndex
    end

    it "passes options along to the index" do
      letter_count_tokenizer = lambda { |str| str.size.to_s }
      Fuzzy::TfIdfIndex.should_receive(:new).with(:source => @books, :tokenizer => letter_count_tokenizer, :attribute => :title)
      @books.fuzzy_index(:attribute => :title, :tokenizer => letter_count_tokenizer)
    end
  end
end