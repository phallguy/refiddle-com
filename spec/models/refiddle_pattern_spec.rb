require 'spec_helper'


describe RefiddlePattern do
  describe "validations" do

    ["/./", "/aa/g", "/k[^s\/]{1,}s*/g"].each do |valid_pattern|
      it "allows #{valid_pattern}" do
        RefiddlePattern.new( regex: valid_pattern ).should be_valid
      end
    end

    ["./", "/aag", ".*" ].each do |invalid_pattern|
      it "prevents #{invalid_pattern}" do
        RefiddlePattern.new( regex: invalid_pattern ).should_not be_valid
      end
    end

  end

  describe "#diff" do
    let(:original){ RefiddlePattern.new( regex: "/k[^\s]*s/g", corpus_text: <<-corpus_text.strip_heredoc, replace_text: <<-replace_text.strip_heredoc
      I can haz kittens. Mmmm. Tasty, tasty kittens.

      Or, bunnies. Mmmm. Bunnnnies.
      corpus_text
      tacos
      replace_text
     )}
    let(:modified){ RefiddlePattern.new( regex: "/[k|b][^\s]*s/g", corpus_text: <<-corpus_text.strip_heredoc, replace_text: <<-replace_text.strip_heredoc
      I can have kittens. Mmmm. Tasty, tasty kittens.

      Or bunnies. Mmmm. Bunnnnies.
      corpus_text
      cakes
      replace_text
     )}

    let(:diff){ original.diff(modified) }

    it "finds diffs in pattern" do
      diff[:regex].should have(2).diffs
      diff[:regex_ex].should have(3).diffs
    end
    it "finds diffs in corpus" do
      diff[:corpus_text].should have(2).diffs
      diff[:corpus_text_ex].should have(7).diffs
    end
    it "finds diffs in replace" do
      diff[:replace_text].should have(2).diffs
      diff[:replace_text_ex].should have(3).diffs
    end

    it "finds small differences" do
      original = RefiddlePattern.new( regex: "/same/", corpus_text: "I can have kittens. Mmmm. Tasty, tasty kittens." )
      modified = RefiddlePattern.new( regex: "/same/", corpus_text: "I can have bunnies. Mmmm. Tasty, tasty kittens." )


      diff = original.diff( modified )
      diff[:corpus_text_ex].should have(4).diffs
      diff[:corpus_text_ex].last.last.should == " Mmmm. Tasty, tasty kittens."
    end

  end
end