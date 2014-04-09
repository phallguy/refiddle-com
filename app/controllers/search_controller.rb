class SearchController < ApplicationController
  skip_authorization_check

  include SearchableController

  def index

    @refiddles = Refiddle.shared
    apply_search "refiddles"

    @refiddles = paged( @refiddles )

  end

end