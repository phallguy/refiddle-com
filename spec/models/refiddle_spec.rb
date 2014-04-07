require 'spec_helper'


describe Refiddle do

  it "delegates" do
    refiddle = create(:refiddle)

    refiddle.regex = "/hello/"
    refiddle.pattern.regex.should == "/hello/"
  end

  it "generates a short code" do
    create(:refiddle).short_code.should_not be_empty
  end

  describe "validations" do
    it "creates a valid fiddle from the factory" do
      create(:refiddle).should be_valid
    end
  end

  describe "versions" do
    let(:refiddle){ create :refiddle, 
      title: "Versioned Fiddle", 
      description: "sample for versioned fiddles.", 
      tags: "phone,validation",
      pattern: { regex: "/versions/", corpus_text: "I'm a version", replace_text: "$1" } 
    }

    it "has a pattern" do
      refiddle.pattern.should_not be_nil
    end

    describe "#commit" do
      before(:each){ refiddle.commit! }

      it "creates a revision" do
        refiddle.revisions.should have(1).revision
      end

      it "copies the pattern" do
        refiddle.revisions.first.regex.should         == "/versions/"
        refiddle.revisions.first.corpus_text.should   == "I'm a version"
        refiddle.revisions.first.replace_text.should  == "$1"
      end

      it "de-references refiddle" do
        refiddle.revisions.first.refiddle.should == refiddle
      end

    end

    describe "#rollback" do
      before(:each) do
        refiddle.commit!
        refiddle.pattern.regex        = "/versioned/"
        refiddle.pattern.corpus_text  = "I'm versioned"
        refiddle.pattern.replace_text = "$2"
        refiddle.save!

        refiddle.rollback!
      end

      it "removes the top revision" do
        refiddle.revisions.should be_empty
      end

      it "restores the pattern" do
        refiddle.pattern.regex.should         == "/versions/"
        refiddle.pattern.corpus_text.should   == "I'm a version"
        refiddle.pattern.replace_text.should  == "$1"
      end

      it "can rollback to nothing" do
        refiddle.rollback!
        refiddle.pattern.regex.should         be_nil
        refiddle.pattern.corpus_text.should   be_nil
        refiddle.pattern.replace_text.should  be_nil
      end
    end

    describe "#fork" do
      let(:fork){ refiddle.fork! }

      it "copies the pattern" do
        fork.pattern.regex.should         == "/versions/"
        fork.pattern.corpus_text.should   == "I'm a version"
        fork.pattern.replace_text.should  == "$1"
      end

      it "does not copy the revision history" do
        fork.revisions.should be_empty
      end

      it "knows where it was forked from" do
        fork.reload.forked_from.should == refiddle
      end

      it "keeps track of it's forks" do
        refiddle.reload.forks.should include(fork)
      end

      %w{ title description tags }.each do |prop|
        it "copies the #{prop} attribute" do
          fork.send(prop).should == refiddle.send(prop)
        end
      end

      %w{ slug short_code }.each do |prop|
        it "doesn't copy the #{prop} attribute" do
          fork.send(prop).should_not == refiddle.send(prop)
        end
      end

    end
  end
end