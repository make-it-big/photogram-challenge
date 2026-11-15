class UsersController < ApplicationController

  before_action :authenticate_user!, only: [:show]

  def index
    matching_users = User.all

    @list_of_users = matching_users.order({ :created_at => :desc })

    render({ :template => "user_templates/index" })
  end


  def show
    the_user_name = params.fetch("username")

    matching_users = User.where({ :username => the_user_name })

    @the_user = matching_users.at(0)
    

    render({ :template => "user_templates/show" })
  end
end
