class Test::SessionsController < ApplicationController
  skip_before_action :authenticate_user!

  PLAYWRIGHT_EMAIL = 'playwright@example.com'

  def create
    raise "Not available outside test environment" unless Rails.env.test?

    user = User.find_or_create_by!(email: PLAYWRIGHT_EMAIL) do |u|
      u.password = u.password_confirmation = 'password123'
    end
    sign_in(user)
    head :ok
  end

  def destroy
    raise "Not available outside test environment" unless Rails.env.test?

    User.find_by(email: PLAYWRIGHT_EMAIL)&.destroy!
    head :ok
  end
end
