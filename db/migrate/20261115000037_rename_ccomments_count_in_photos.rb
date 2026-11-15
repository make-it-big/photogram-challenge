class RenameCcommentsCountInPhotos < ActiveRecord::Migration[8.1]
  def change
    rename_column :photos, :ccomments_count, :comments_count
  end
end
