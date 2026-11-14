desc "Fill the database tables with some sample data"
task({ :sample_data => :environment }) do
  starting = Time.now

  puts "Generating sample data"

  # Start from empty tables, and number the new rows from 1.
  [ Like, Comment, FollowRequest, Photo, User ].each do |model|
    model.delete_all

    ActiveRecord::Base.connection.reset_pk_sequence!(model.table_name)
  end

  # Remove the files that earlier runs uploaded.
  FileUtils.rm_rf(Rails.root.join("public", "uploads", "photo"))

  #------------------------------
  # Users. Everyone's password is "appdev".

  users = [
    { :username => "alice", :private => true },
    { :username => "bob", :private => false },
    { :username => "carol", :private => true },
    { :username => "dave", :private => false },
    { :username => "eve", :private => false },
    { :username => "frank", :private => false },
    { :username => "grace", :private => true },
    { :username => "henry", :private => false },
    { :username => "isla", :private => false },
    { :username => "jack", :private => false },
    { :username => "kira", :private => false },
    { :username => "leo", :private => false }
  ]

  users.each_with_index do |a_user, index|
    user = User.new
    user.username = a_user.fetch(:username)
    user.email = "#{a_user.fetch(:username)}@example.com"
    user.private = a_user.fetch(:private)
    user.likes_count = 0
    user.comments_count = 0
    user.created_at = (60 - index).days.ago

    # Only once Devise (or has_secure_password) is in place:
    if user.respond_to?(:password=)
      user.password = "appdev"
    end

    user.save(:validate => false)
  end

  ids = {}

  User.all.each do |user|
    ids.store(user.username, user.id)
  end

  #------------------------------
  # Follow requests: sender, recipient, status. A request to a public user is
  # accepted right away; alice, carol, and grace are private, so theirs wait.

  follow_requests = [
    [ "alice", "bob", "accepted" ],
    [ "alice", "carol", "accepted" ],
    [ "alice", "henry", "accepted" ],
    [ "bob", "alice", "accepted" ],
    [ "bob", "carol", "accepted" ],
    [ "bob", "dave", "accepted" ],
    [ "bob", "isla", "accepted" ],
    [ "carol", "alice", "accepted" ],
    [ "carol", "eve", "accepted" ],
    [ "carol", "leo", "accepted" ],
    [ "dave", "bob", "accepted" ],
    [ "dave", "eve", "accepted" ],
    [ "dave", "frank", "accepted" ],
    [ "dave", "alice", "pending" ],
    [ "dave", "carol", "rejected" ],
    [ "frank", "bob", "accepted" ],
    [ "frank", "jack", "accepted" ],
    [ "frank", "alice", "pending" ],
    [ "frank", "grace", "pending" ],
    [ "grace", "bob", "accepted" ],
    [ "grace", "henry", "accepted" ],
    [ "henry", "grace", "accepted" ],
    [ "henry", "dave", "accepted" ],
    [ "henry", "isla", "accepted" ],
    [ "isla", "eve", "accepted" ],
    [ "isla", "grace", "accepted" ],
    [ "isla", "leo", "accepted" ],
    [ "jack", "bob", "accepted" ],
    [ "jack", "isla", "accepted" ],
    [ "jack", "kira", "accepted" ],
    [ "kira", "frank", "accepted" ],
    [ "kira", "leo", "accepted" ],
    [ "kira", "carol", "pending" ],
    [ "leo", "eve", "accepted" ],
    [ "leo", "kira", "accepted" ]
  ]

  follow_request_rows = []

  follow_requests.each_with_index do |a_follow_request, index|
    sent_at = (40 - index).days.ago

    follow_request_rows.push({
      :sender_id => ids.fetch(a_follow_request.at(0)),
      :recipient_id => ids.fetch(a_follow_request.at(1)),
      :status => a_follow_request.at(2),
      :created_at => sent_at,
      :updated_at => sent_at
    })
  end

  FollowRequest.insert_all!(follow_request_rows)

  #------------------------------
  # Photos: owner, file in public/sample_photos, caption. Oldest first.

  photos = [
    [ "alice", "cat.jpg", "Somebody wants breakfast." ],
    [ "bob", "path.jpg", "My new running route." ],
    [ "carol", "blossoms.jpg", "Spring finally showed up." ],
    [ "dave", "mountains.jpg", "Above the clouds this morning." ],
    [ "eve", "village.jpg", "Every wall here is this white." ],
    [ "frank", "records.jpg", "Sunday records." ],
    [ "grace", "lighthouse.jpg", "Storm rolling in." ],
    [ "henry", "tractor.jpg", "Harvest week." ],
    [ "isla", "bridge.jpg", "The city never looks the same twice." ],
    [ "jack", "tracks.jpg", "Waiting on the 7:15." ],
    [ "kira", "trees.jpg", "Took the long way home." ],
    [ "leo", "swing.jpg", "Best seat in town." ],
    [ "alice", "book.jpg", "Halfway through. No spoilers, please." ],
    [ "bob", "glove.jpg", "First catch of the season." ],
    [ "carol", "grapes.jpg", "Almost ready to pick." ],
    [ "dave", "waterfall.jpg", "Worth the two-hour hike." ],
    [ "eve", "tuk_tuk.jpg", "Our ride for the day." ],
    [ "frank", "desk.jpg", "Trying to keep the desk this tidy." ],
    [ "grace", "pier.jpg", "End of the pier." ],
    [ "henry", "bicycle.jpg", "Found this one leaning against the shed." ],
    [ "isla", "lights.jpg", "Lights downtown." ],
    [ "jack", "commute.jpg", "Evening commute." ],
    [ "kira", "sunrise.jpg", "Up early for this." ],
    [ "leo", "bench.jpg", "Saving you a seat." ],
    [ "alice", "mug.jpg", "The only mug that matters." ],
    [ "bob", "coffee.jpg", "Coffee first." ],
    [ "carol", "door.jpg", "I'd love to know who lives here." ],
    [ "dave", "summit.jpg", "Made it to the top." ],
    [ "eve", "coast.jpg", "Lunch spot." ],
    [ "frank", "laptop.jpg", "Office for the afternoon." ],
    [ "grace", "beach.jpg", "Low tide." ],
    [ "henry", "desert.jpg", "Not a single tree for miles." ],
    [ "isla", "street.jpg", "Quiet street before everyone wakes up." ],
    [ "jack", "cafe.jpg", "New favorite corner table." ],
    [ "kira", "camp.jpg", "Camp view." ],
    [ "leo", "cactus.jpg", "Don't touch." ]
  ]

  photos.each_with_index do |a_photo, index|
    filename = a_photo.at(1)
    posted_at = ((photos.count - index) * 19 - 16).hours.ago

    photo = Photo.new
    photo.owner_id = ids.fetch(a_photo.at(0))
    photo.caption = a_photo.at(2)
    photo.likes_count = 0
    photo.comments_count = 0
    photo.created_at = posted_at
    photo.updated_at = posted_at

    if Photo.respond_to?(:uploaders) && Photo.uploaders.has_key?(:image)
      # Image uploads are set up, so hand the file to the uploader, as if
      # someone had chosen it in the form.
      photo.image = File.open(Rails.root.join("public", "sample_photos", filename))
    else
      # Until then, the column holds a plain path that an <img> can use.
      photo.image = "/sample_photos/#{filename}"
    end

    photo.save(:validate => false)
  end

  #------------------------------
  # Likes and comments, only from people who are allowed to see the photo.
  # (The arithmetic below just spreads them around unevenly, the same way
  # every time.)

  comments = [
    "Love this!",
    "Where is this?",
    "So jealous.",
    "This made my day.",
    "Great shot!",
    "I need to go there.",
    "Wow.",
    "Saving this one.",
    "Teach me your ways!",
    "Gorgeous colors.",
    "Take me with you next time.",
    "Framing this.",
    "No way!",
    "The light in this is perfect.",
    "Okay, this is my favorite.",
    "You always find the best spots."
  ]

  like_rows = []
  comment_rows = []

  Photo.all.order({ :id => :asc }).each_with_index do |photo, photo_index|
    owner = User.where({ :id => photo.owner_id }).at(0)

    User.all.order({ :id => :asc }).each_with_index do |user, user_index|
      if user.id == owner.id
        next
      end

      follows_owner = FollowRequest.where({ :sender_id => user.id, :recipient_id => owner.id, :status => "accepted" }).count > 0

      if owner.private == true && follows_owner == false
        next
      end

      if (photo_index * 5 + user_index * 7 + photo_index * user_index) % 11 < 5
        liked_at = photo.created_at + ((user_index + 1) * 7).minutes

        like_rows.push({ :fan_id => user.id, :photo_id => photo.id, :created_at => liked_at, :updated_at => liked_at })
      end

      if (photo_index * 3 + user_index * 5 + photo_index * user_index) % 13 < 3
        commented_at = photo.created_at + ((user_index + 1) * 9).minutes

        comment_rows.push({
          :author_id => user.id,
          :photo_id => photo.id,
          :body => comments.at((photo_index + user_index) % comments.count),
          :created_at => commented_at,
          :updated_at => commented_at
        })
      end
    end
  end

  Like.insert_all!(like_rows)
  Comment.insert_all!(comment_rows)

  #------------------------------
  # Fill in the columns that keep count, so they agree with the rows.

  Photo.all.each do |photo|
    photo.update_columns({
      :likes_count => Like.where({ :photo_id => photo.id }).count,
      :comments_count => Comment.where({ :photo_id => photo.id }).count
    })
  end

  User.all.each do |user|
    user.update_columns({
      :likes_count => Like.where({ :fan_id => user.id }).count,
      :comments_count => Comment.where({ :author_id => user.id }).count
    })
  end

  ending = Time.now

  puts "There are now #{User.count} users, #{Photo.count} photos, #{Like.count} likes, #{Comment.count} comments, and #{FollowRequest.count} follow requests."
  puts "Sign in as any of them (alice@example.com, bob@example.com, ...) with the password: appdev"
  puts "#{(ending - starting).to_i} seconds elapsed."
end
