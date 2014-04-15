require 'spec_helper'


feature 'playing fiddles', :focus, js: true do

    it "updates the corpus" do
      visit root_path
      find( "#page-actions .play" ).click

      page.should have_selector("#corpus span.match")
      page.should_not have_selector("#corpus span.nomatch")
    end

end