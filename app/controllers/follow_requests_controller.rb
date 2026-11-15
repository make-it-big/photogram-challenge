class FollowRequestsController < ApplicationController
  def index
    matching_follow_requests = FollowRequest.all

    @list_of_follow_requests = matching_follow_requests.order({ :created_at => :desc })

    render({ :template => "follow_request_templates/index" })
  end

  def show
    the_id = params.fetch("path_id")

    matching_follow_requests = FollowRequest.where({ :id => the_id })

    @the_follow_request = matching_follow_requests.at(0)

    render({ :template => "follow_request_templates/show" })
  end

  def create
    recipient = User.where({ :id => params.fetch("recipient_id_param") }).at(0)

    if recipient.nil?
      redirect_to("/", { :alert => "That user doesn't exist." })
      return
    end

    the_follow_request = FollowRequest.new
    the_follow_request.sender_id = current_user.id
    the_follow_request.recipient_id = recipient.id

    if recipient.private
      the_follow_request.status = "pending"
    else
      the_follow_request.status = "accepted"
    end

    if the_follow_request.save
      redirect_to("/users/#{recipient.username}", { :notice => "Follow request created successfully." })
    else
      redirect_to("/users/#{recipient.username}", { :alert => the_follow_request.errors.full_messages.to_sentence })
    end
  end

  def update
    the_id = params.fetch("path_id")
    the_follow_request = FollowRequest.where({ :id => the_id }).at(0)

    the_follow_request.status = params.fetch("status_param")

    if the_follow_request.valid? && the_follow_request.recipient_id == current_user.id
      the_follow_request.save
      redirect_to("/users/#{the_follow_request.recipient.username}", { :notice => "Follow request updated successfully." } )
    else
      redirect_to("/users/#{the_follow_request.recipient.username}", { :alert => the_follow_request.errors.full_messages.to_sentence })
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_follow_request = current_user.sent_follow_requests.where({ :id => the_id }).at(0)

    if the_follow_request.nil?
      redirect_to("/", { :alert => "You can't delete that follow request." })
    else
      recipient = the_follow_request.recipient
      the_follow_request.destroy

      redirect_to("/users/#{recipient.username}", { :notice => "Follow request deleted successfully." })
    end
  end
end
