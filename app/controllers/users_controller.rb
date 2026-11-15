class UsersController < ApplicationController

  before_action :authenticate_user!, only: [:show, :feed, :discover]

  def index
    matching_users = User.all

    @list_of_users = matching_users.order({ :created_at => :desc })

    render({ :template => "user_templates/index" })
  end

  def feed

    my_accepted_requests = current_user.sent_follow_requests.where({ :status => "accepted" })
    following_ids = my_accepted_requests.pluck(:recipient_id)
    @feed_photos = Photo.where({ :owner_id => following_ids }).order({ :created_at => :desc })

    render({ :template => "user_templates/feed" })

  end

  def discover
    # People a user follows
    my_accepted_requests = current_user.sent_follow_requests.where({ :status => "accepted" })
    following_ids = my_accepted_requests.pluck(:recipient_id)

    # Condition 1: photos liked by people I follow
    photos_liked_by_following_users = Like.where({ :fan_id => following_ids }).pluck(:photo_id)

    # Condition 2: owners I'm allowed to see
    public_user_ids = User.where({ :private => false }).pluck(:id)
    allowed_owner_ids = public_user_ids + following_ids + [current_user.id]

    # Both conditions together
    @discovered_photos = Photo.where({ :id => photos_liked_by_following_users, :owner_id => allowed_owner_ids }).order({ :created_at => :desc })

    render({ :template => "user_templates/discover" })
  end

  def show
    the_user_name = params.fetch("username")

    matching_users = User.where({ :username => the_user_name })

    @the_user = matching_users.at(0)
    

    render({ :template => "user_templates/show" })
  end
end
