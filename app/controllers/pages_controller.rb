class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index, :privacy, :terms, :about ]

  def about
    http_cache_forever(public: true) { render }
  end

  def privacy
    http_cache_forever(public: true) { render }
  end

  def terms
    http_cache_forever(public: true) { render }
  end
end
