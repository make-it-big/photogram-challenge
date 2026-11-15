class RenameRecepientIdInFollowRequests < ActiveRecord::Migration[8.1]
  def change
    rename_column :follow_requests, :recepient_id, :recipient_id
  end
end
