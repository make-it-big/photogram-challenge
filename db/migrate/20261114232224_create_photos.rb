class CreatePhotos < ActiveRecord::Migration[8.1]
  def change
    create_table :photos do |t|
      t.text :caption
      t.integer :ccomments_count
      t.string :image
      t.integer :likes_count
      t.integer :owner_id

      t.timestamps
    end
  end
end
