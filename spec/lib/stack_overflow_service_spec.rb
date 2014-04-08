require 'spec_helper'
require 'stack_overflow_service'

describe StackOverflowService, :focus, vcr: { record: :new_episodes } do
  let(:service){ StackOverflowService.new }
  let(:results){ service.fetch_questions("regex") }
  let(:question){ service.fetch_question( results[:questions].first[:question_id] ) }

  it "finds some questions" do
    results[:questions].should have(100).questions
  end

  it "can get a question's details" do
    question.should_not be_nil
  end

end