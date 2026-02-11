class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :privacy, :terms]

  def privacy
  end

  def terms
  end
end
