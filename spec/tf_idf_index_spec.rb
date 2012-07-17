require 'spec_helper'

describe FuzzyTools::TfIdfIndex do
  it "takes a source" do
    vegetables = ["mushroom", "olive", "tomato"]
    index = FuzzyTools::TfIdfIndex.new(:source => vegetables)
    index.source.should == vegetables
  end

  it "indexes on to_s by default" do
    index = FuzzyTools::TfIdfIndex.new(:source => 1..3)
    index.find("2").should == 2
  end

  it "defaults tokenizer to FuzzyTools::Tokenizers::HYBRID" do
    FuzzyTools::TfIdfIndex.new(:source => []).tokenizer.should == FuzzyTools::Tokenizers::HYBRID
  end

  it "takes any proc as a tokenizer" do
    foods = ["muffins", "pancakes"]
    letter_count_tokenizer = lambda { |str| str.size.to_s }
    index = FuzzyTools::TfIdfIndex.new(:source => foods, :tokenizer => letter_count_tokenizer)

    index.tokenizer.should == letter_count_tokenizer
    index.find("octoword").should == "pancakes"
  end

  context "indexing objects" do
    before :each do
      @till_we_have_faces = Book.new("Till We Have Faces", "C.S. Lewis" )
      @ecclesiates        = Book.new("Ecclesiates",        "The Teacher")
      @the_prodigal_god   = Book.new("The Prodigal God",   "Tim Keller" )

      @books = [
        @till_we_have_faces,
        @ecclesiates,
        @the_prodigal_god,
      ]
    end

    it "indexes on the method specified in :attribute" do
      index = FuzzyTools::TfIdfIndex.new(:source => @books, :attribute => :title)
      index.find("ecklestica").should == @ecclesiates
    end

    it "indexes the proc result if a proc is given for :attribute" do
      index = FuzzyTools::TfIdfIndex.new(:source => @books, :attribute => lambda { |book| book.title + " " + book.author })
      index.find("prodigy").should == @the_prodigal_god
      index.find("LEWIS").should   == @till_we_have_faces
    end
  end

  context "indexing hashes" do
    before :each do
      @till_we_have_faces = { :title => "Till We Have Faces", :author => "C.S. Lewis"  }
      @ecclesiates        = { :title => "Ecclesiates",        :author => "The Teacher" }
      @the_prodigal_god   = { :title => "The Prodigal God",   :author => "Tim Keller"  }

      @books = [
        @till_we_have_faces,
        @ecclesiates,
        @the_prodigal_god,
      ]
    end

    it "indexes on the hash key specified in :attribute" do
      index = FuzzyTools::TfIdfIndex.new(:source => @books, :attribute => :title)
      index.find("ecklestica").should == @ecclesiates
    end

    it "indexes the proc result if a proc is given for :attribute" do
      index = FuzzyTools::TfIdfIndex.new(:source => @books, :attribute => lambda { |book| book[:title] + " " + book[:author] })
      index.find("prodigy").should == @the_prodigal_god
      index.find("LEWIS").should   == @till_we_have_faces
    end
  end

  context "query methods" do
    describe "#find" do
      it "returns the best result" do
        mushy_stuff = ["mushrooms", "mushroom", "mushy pit", "ABC"]
        index = FuzzyTools::TfIdfIndex.new(:source => mushy_stuff)

        index.find("ushr").should == "mushroom"
      end

      it "calls to_s on input" do
        index = FuzzyTools::TfIdfIndex.new(:source => 1..3)
        index.find(2).should == 2
      end

      it "returns nil if no results" do
        index = FuzzyTools::TfIdfIndex.new(:source => 1..3)
        index.find("bubble").should be_nil
      end
    end

    describe "#all" do
      it "returns all results, from best to worst" do
        mushy_stuff = ["mushrooms", "mushroom", "mushy pit", "ABC"]
        index = FuzzyTools::TfIdfIndex.new(:source => mushy_stuff)

        index.all("ushr").should == [
          "mushroom",
          "mushrooms",
          "mushy pit"
        ]
      end

      it "calls to_s on input" do
        index = FuzzyTools::TfIdfIndex.new(:source => 1..3)
        index.all(2).first.should == 2
      end

      it "returns an empty array if no results" do
        index = FuzzyTools::TfIdfIndex.new(:source => 1..3)
        index.all("bubble").should == []
      end
    end


    describe "#all" do
      it "returns all results, from best to worst" do
        mushy_stuff = ["mushrooms", "mushroom", "mushy pit", "ABC"]
        index = FuzzyTools::TfIdfIndex.new(:source => mushy_stuff)

        index.all("ushr").should == [
          "mushroom",
          "mushrooms",
          "mushy pit"
        ]
      end

      it "calls to_s on input" do
        index = FuzzyTools::TfIdfIndex.new(:source => 1..3)
        index.all(2).first.should == 2
      end

      it "returns an empty array if no results" do
        index = FuzzyTools::TfIdfIndex.new(:source => 1..3)
        index.all("bubble").should == []
      end
    end

    describe "#all_with_scores" do
      it "returns ordered array of arrays of score and results" do
        mushy_stuff = ["mushrooms", "mushroom", "mushy pit", "ABC"]
        index = FuzzyTools::TfIdfIndex.new(:source => mushy_stuff)

        results = index.all_with_scores("ushr")

        results.map(&:last).should == [
          "mushroom",
          "mushrooms",
          "mushy pit"
        ]

        results.sort.reverse.should == results

        results.map(&:first).each { |score| score.class.should == Float }
        results.map(&:first).each { |score| score.should > 0.0 }
        results.map(&:first).each { |score| score.should < 1.0 }
        results.map(&:first).uniq.should == results.map(&:first)
      end

      it "calls to_s on input" do
        index = FuzzyTools::TfIdfIndex.new(:source => 1..3)
        index.all_with_scores(2).first.should == [1.0, 2]
      end

      it "returns an empty array if no results" do
        index = FuzzyTools::TfIdfIndex.new(:source => 1..3)
        index.all_with_scores("bubble").should == []
      end
    end
  end
end