class HomeController < ApplicationController
  def index
    @info_uncompleted = current_user && current_user.completed_info?.blank?
  end
end
