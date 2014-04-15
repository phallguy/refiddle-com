require 'spec_helper'

describe "Fiddling" do
  let(:admin){ create :user, :admin }
  let(:owner){ create :user }
  let(:visitor){ create :user }

  it "works" do
    get "/"
  end

  it "creates a new fiddle" do
    post "/refiddles", refiddle: { pattern_attributes: { regex: "/test/", corpus_text: "corpus" } }

    expect(response).to redirect_to(assigns(:refiddle))
    follow_redirect!

    expect(response.body).to include("/test/")
  end

  it "updates an existing fiddle and commits the change" do
    fiddle = create(:refiddle, pattern: { regex: "/test/", corpus_text: "corpus" }, user: owner )
    login owner

    Refiddle.any_instance.should_receive(:commit!)
    put "/refiddles/#{fiddle.id}", refiddle: { pattern_attributes: { regex: "/updated/" } }

    assigns(:refiddle).pattern.regex.should == "/updated/"
  end

  it "updates an existing fiddle but does not commit for auto save" do
    fiddle = create(:refiddle, pattern: { regex: "/test/", corpus_text: "corpus" }, user: owner )
    login owner

    Refiddle.any_instance.should_not_receive(:commit!)
    put "/refiddles/#{fiddle.id}", refiddle: { pattern_attributes: { regex: "/updated/" } }, autosave: true

    assigns(:refiddle).pattern.regex.should == "/updated/"
  end

  it "updates if not locked and edited by another user" do
    fiddle = create(:refiddle, pattern: { regex: "/test/", corpus_text: "corpus" }, user: owner )
    login visitor

    Refiddle.any_instance.should_receive(:commit!)
    put "/refiddles/#{fiddle.id}", refiddle: { pattern_attributes: { regex: "/updated/" } }

    assigns(:refiddle).pattern.regex.should == "/updated/"
    assigns(:refiddle).id.should == fiddle.id
    assigns(:refiddle).user.should == owner
  end

  it "forks if locked and edited by another user" do
    fiddle = create(:refiddle, pattern: { regex: "/test/", corpus_text: "corpus" }, user: owner, locked: true )
    login visitor

    Refiddle.any_instance.should_receive(:fork!).and_call_original
    put "/refiddles/#{fiddle.id}", refiddle: { pattern_attributes: { regex: "/updated/" } }, autosave: true

    assigns(:refiddle).pattern.regex.should == "/updated/"
    assigns(:refiddle).id.should_not == fiddle.id
    assigns(:refiddle).user.should == visitor
  end

end