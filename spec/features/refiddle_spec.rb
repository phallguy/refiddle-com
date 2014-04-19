require 'spec_helper'


feature 'playing fiddles', js: true do

    it "updates the corpus" do
      visit root_path
      find( "#page-actions .play", visible: false ).click

      page.should have_selector("#corpus span.match")
      page.should_not have_selector("#corpus span.nomatch")
    end

    it "shows error on invalid regex", :focus do
      visit root_path
      page.evaluate_script "window.refiddle.regexEditor.setValue('/in[valid')"
      page.should_not have_selector("#corpus.refreshing")
      page.should have_selector(".alert.alert-danger")
    end



end