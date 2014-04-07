require 'spec_helper'


describe RefiddlePattern do
  describe "validations" do

    ["/./", "/aa/g"].each do |valid_pattern|
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
end