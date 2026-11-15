class LikesController < ApplicationController
  def index
    matching_likes = Like.all

    @list_of_likes = matching_likes.order({ :created_at => :desc })

    render({ :template => "like_templates/index" })
  end

  def show
    the_id = params.fetch("path_id")

    matching_likes = Like.where({ :id => the_id })

    @the_like = matching_likes.at(0)

    render({ :template => "like_templates/show" })
  end

  def create
    the_like = Like.new
    the_like.fan_id = current_user.id
    the_like.photo_id = params.fetch("photo_id_param")

    if the_like.valid?
      the_like.save
      redirect_to("/photos/#{the_like.photo_id}", { :notice => "Like created successfully." })
    else
      redirect_to("/photos/#{the_like.photo_id}", { :alert => the_like.errors.full_messages.to_sentence })
    end
  end

  def update
    the_id = params.fetch("path_id")
    the_like = Like.where({ :id => the_id }).at(0)

    the_like.fan_id = params.fetch("fan_id_param")
    the_like.photo_id = params.fetch("photo_id_param")

    if the_like.valid?
      the_like.save
      redirect_to("/likes/#{the_like.id}", { :notice => "Like updated successfully." } )
    else
      redirect_to("/likes/#{the_like.id}", { :alert => the_like.errors.full_messages.to_sentence })
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_like = Like.where({ :photo_id => the_id, :fan_id => current_user.id }).at(0)

      if the_like.present?
        the_photo_id = the_like.photo_id
        the_like.destroy

        redirect_to("/photos/#{the_photo_id}", { :notice => "Like deleted successfully." })
      else
        redirect_to("/photos", { :alert => "You can only remove your own likes." })
      end
  end
end
