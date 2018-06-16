class StaticPagesController < ApplicationController
  def home
	  if signed_in?
		  redirect_to mturk_tasks_url
	  end
  end

  def help
  end
end
