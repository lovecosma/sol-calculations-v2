class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :privacy, :terms, :about]

  def about
    http_cache_forever public: true
  end

  def privacy
    http_cache_forever public: true
  end

  def terms
    http_cache_forever public: true
  end
end
