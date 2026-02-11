class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :privacy]

  def privacy
  end
end
