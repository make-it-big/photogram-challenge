class PhotosController < ApplicationController
  def index
    matching_photos = Photo.all

    @list_of_photos = matching_photos.order({ :created_at => :desc })

    render({ :template => "photo_templates/index" })
  end

  def show
    the_id = params.fetch("path_id")

    matching_photos = Photo.where({ :id => the_id })
    matching_likes = Like.where({ :photo_id => the_id })
    current_user_like_status = matching_likes.where({ :fan_id => current_user.id }).any?
    matching_comments = Comment.where({ :photo_id => the_id })

    @the_photo = matching_photos.at(0)
    @list_of_likes = matching_likes
    @current_user_like_status = current_user_like_status
    @list_of_comments = matching_comments

    if current_user.present?
      render({ :template => "photo_templates/show" })
    else
      redirect_to("/users/sign_in", { :alert => "You need to sign in or sign up before continuing." })
    end
  end

  def create
    the_photo = Photo.new
    the_photo.caption = params.fetch("caption_param")
    the_photo.ccomments_count = params.fetch("ccomments_count_param")
    the_photo.image = params.fetch("image_param")
    the_photo.likes_count = params.fetch("likes_count_param")
    the_photo.owner_id = params.fetch("owner_id_param")

    if the_photo.valid?
      the_photo.save
      redirect_to("/photos", { :notice => "Photo created successfully." })
    else
      redirect_to("/photos", { :alert => the_photo.errors.full_messages.to_sentence })
    end
  end

  def update
    the_id = params.fetch("path_id")
    the_photo = Photo.where({ :id => the_id }).at(0)

    the_photo.caption = params.fetch("caption_param")
    the_photo.ccomments_count = params.fetch("ccomments_count_param")
    the_photo.image = params.fetch("image_param")
    the_photo.likes_count = params.fetch("likes_count_param")
    the_photo.owner_id = params.fetch("owner_id_param")

    if the_photo.valid?
      the_photo.save
      redirect_to("/photos/#{the_photo.id}", { :notice => "Photo updated successfully." } )
    else
      redirect_to("/photos/#{the_photo.id}", { :alert => the_photo.errors.full_messages.to_sentence })
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_photo = Photo.where({ :id => the_id }).at(0)

    the_photo.destroy

    redirect_to("/photos", { :notice => "Photo deleted successfully." } )
  end
end
