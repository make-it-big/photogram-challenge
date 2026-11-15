class CommentsController < ApplicationController
  def index
    matching_comments = Comment.all

    @list_of_comments = matching_comments.order({ :created_at => :desc })

    render({ :template => "comment_templates/index" })
  end

  def show
    the_id = params.fetch("path_id")

    matching_comments = Comment.where({ :id => the_id })

    @the_comment = matching_comments.at(0)

    render({ :template => "comment_templates/show" })
  end

  def create
    the_comment = Comment.new
    the_comment.author_id = params.fetch("author_id_param")
    the_comment.body = params.fetch("body_param")
    the_comment.photo_id = params.fetch("photo_id_param")

    if the_comment.valid?
      the_comment.save
      redirect_to("/comments", { :notice => "Comment created successfully." })
    else
      redirect_to("/comments", { :alert => the_comment.errors.full_messages.to_sentence })
    end
  end

  def update
    the_id = params.fetch("path_id")
    the_comment = Comment.where({ :id => the_id }).at(0)

    the_comment.author_id = params.fetch("author_id_param")
    the_comment.body = params.fetch("body_param")
    the_comment.photo_id = params.fetch("photo_id_param")

    if the_comment.valid?
      the_comment.save
      redirect_to("/comments/#{the_comment.id}", { :notice => "Comment updated successfully." } )
    else
      redirect_to("/comments/#{the_comment.id}", { :alert => the_comment.errors.full_messages.to_sentence })
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_comment = Comment.where({ :id => the_id }).at(0)

    the_comment.destroy

    redirect_to("/comments", { :notice => "Comment deleted successfully." } )
  end
end
