class CreateFollowRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :follow_requests do |t|
      t.integer :recepient_id
      t.integer :sender_id
      t.string :status

      t.timestamps
    end
  end
end
