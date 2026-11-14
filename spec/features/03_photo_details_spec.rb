require "rails_helper"

describe "/photos/[ID]" do
  it "sends a visitor who isn't signed in to the sign-in page", points: 1, hint: h("require_sign_in") do
    bob = User.new
    bob.email = "bob@example.com"
    bob.password = "password"
    bob.username = "bob"
    bob.private = false
    bob.save

    photo = Photo.new
    photo.owner_id = bob.id
    photo.caption = "Sunset over the lake"
    photo.image = File.open("#{Rails.root}/spec/support/kirb.gif")
    photo.save

    visit "/photos/#{photo.id}"

    expect(page).to have_current_path("/users/sign_in"),
      "Expected to be redirected to '/users/sign_in' when not signed in, but ended up at '#{page.current_path}'."
  end
end

describe "/photos/[ID]" do
  it "displays the photo in an <img> element", points: 1, hint: h("real_image_uploads") do
    alice = User.new
    alice.email = "alice@example.com"
    alice.password = "password"
    alice.username = "alice"
    alice.private = false
    alice.save

    bob = User.new
    bob.email = "bob@example.com"
    bob.password = "password"
    bob.username = "bob"
    bob.private = false
    bob.save

    photo = Photo.new
    photo.owner_id = bob.id
    photo.caption = "Sunset over the lake"
    photo.image = File.open("#{Rails.root}/spec/support/kirb.gif")
    photo.save

    visit "/users/sign_in"

    fill_in "Email", with: alice.email
    fill_in "Password", with: alice.password
    click_button "Log in"

    visit "/photos/#{photo.id}"

    expect(page).to have_css("img[src*='kirb.gif']"),
      "Expected to find an <img> whose src contains the uploaded file's name, 'kirb.gif', but didn't find one."
  end
end

describe "/photos/[ID]" do
  it "displays the caption", points: 1 do
    alice = User.new
    alice.email = "alice@example.com"
    alice.password = "password"
    alice.username = "alice"
    alice.private = false
    alice.save

    bob = User.new
    bob.email = "bob@example.com"
    bob.password = "password"
    bob.username = "bob"
    bob.private = false
    bob.save

    photo = Photo.new
    photo.owner_id = bob.id
    photo.caption = "Sunset over the lake"
    photo.image = File.open("#{Rails.root}/spec/support/kirb.gif")
    photo.save

    visit "/users/sign_in"

    fill_in "Email", with: alice.email
    fill_in "Password", with: alice.password
    click_button "Log in"

    visit "/photos/#{photo.id}"

    expect(page).to have_text("Sunset over the lake"),
      "Expected to find the caption 'Sunset over the lake', but didn't."
  end
end

describe "/photos/[ID]" do
  it "displays the owner's username, linked to their profile", points: 1 do
    alice = User.new
    alice.email = "alice@example.com"
    alice.password = "password"
    alice.username = "alice"
    alice.private = false
    alice.save

    bob = User.new
    bob.email = "bob@example.com"
    bob.password = "password"
    bob.username = "bob"
    bob.private = false
    bob.save

    photo = Photo.new
    photo.owner_id = bob.id
    photo.caption = "Sunset over the lake"
    photo.image = File.open("#{Rails.root}/spec/support/kirb.gif")
    photo.save

    visit "/users/sign_in"

    fill_in "Email", with: alice.email
    fill_in "Password", with: alice.password
    click_button "Log in"

    visit "/photos/#{photo.id}"

    expect(page).to have_link("bob", href: "/users/bob"),
      "Expected to find a link with the text 'bob' to '/users/bob', but didn't find one."
  end
end

describe "/photos/[ID]" do
  it "displays how long ago the photo was posted", points: 1, hint: h("time_ago") do
    alice = User.new
    alice.email = "alice@example.com"
    alice.password = "password"
    alice.username = "alice"
    alice.private = false
    alice.save

    bob = User.new
    bob.email = "bob@example.com"
    bob.password = "password"
    bob.username = "bob"
    bob.private = false
    bob.save

    photo = Photo.new
    photo.owner_id = bob.id
    photo.caption = "Sunset over the lake"
    photo.image = File.open("#{Rails.root}/spec/support/kirb.gif")
    photo.created_at = 50.minutes.ago
    photo.save

    visit "/users/sign_in"

    fill_in "Email", with: alice.email
    fill_in "Password", with: alice.password
    click_button "Log in"

    visit "/photos/#{photo.id}"

    expect(page).to have_text("about 1 hour ago"),
      "Expected a photo posted 50 minutes ago to say 'about 1 hour ago', but didn't find that."
  end
end

describe "/photos/[ID]" do
  it "displays the number of likes", points: 1, hint: h("count_rows") do
    alice = User.new
    alice.email = "alice@example.com"
    alice.password = "password"
    alice.username = "alice"
    alice.private = false
    alice.save

    bob = User.new
    bob.email = "bob@example.com"
    bob.password = "password"
    bob.username = "bob"
    bob.private = false
    bob.save

    dave = User.new
    dave.email = "dave@example.com"
    dave.password = "password"
    dave.username = "dave"
    dave.private = false
    dave.save

    photo = Photo.new
    photo.owner_id = bob.id
    photo.caption = "Sunset over the lake"
    photo.image = File.open("#{Rails.root}/spec/support/kirb.gif")
    photo.save

    first_like = Like.new
    first_like.fan_id = alice.id
    first_like.photo_id = photo.id
    first_like.save

    second_like = Like.new
    second_like.fan_id = dave.id
    second_like.photo_id = photo.id
    second_like.save

    visit "/users/sign_in"

    fill_in "Email", with: alice.email
    fill_in "Password", with: alice.password
    click_button "Log in"

    visit "/photos/#{photo.id}"

    expect(page).to have_text("2 likes"),
      "Expected a photo that two users have liked to say '2 likes', but didn't find that."
  end
end

describe "/photos/[ID]" do
  it "displays the number of comments", points: 1, hint: h("count_rows") do
    alice = User.new
    alice.email = "alice@example.com"
    alice.password = "password"
    alice.username = "alice"
    alice.private = false
    alice.save

    bob = User.new
    bob.email = "bob@example.com"
    bob.password = "password"
    bob.username = "bob"
    bob.private = false
    bob.save

    dave = User.new
    dave.email = "dave@example.com"
    dave.password = "password"
    dave.username = "dave"
    dave.private = false
    dave.save

    photo = Photo.new
    photo.owner_id = bob.id
    photo.caption = "Sunset over the lake"
    photo.image = File.open("#{Rails.root}/spec/support/kirb.gif")
    photo.save

    first_comment = Comment.new
    first_comment.author_id = alice.id
    first_comment.photo_id = photo.id
    first_comment.body = "What a view"
    first_comment.save

    second_comment = Comment.new
    second_comment.author_id = dave.id
    second_comment.photo_id = photo.id
    second_comment.body = "Wish I were there"
    second_comment.save

    visit "/users/sign_in"

    fill_in "Email", with: alice.email
    fill_in "Password", with: alice.password
    click_button "Log in"

    visit "/photos/#{photo.id}"

    expect(page).to have_text("2 comments"),
      "Expected a photo with two comments to say '2 comments', but didn't find that."
  end
end

describe "/photos/[ID]" do
  it "displays each comment with its author's username", points: 1 do
    alice = User.new
    alice.email = "alice@example.com"
    alice.password = "password"
    alice.username = "alice"
    alice.private = false
    alice.save

    bob = User.new
    bob.email = "bob@example.com"
    bob.password = "password"
    bob.username = "bob"
    bob.private = false
    bob.save

    dave = User.new
    dave.email = "dave@example.com"
    dave.password = "password"
    dave.username = "dave"
    dave.private = false
    dave.save

    photo = Photo.new
    photo.owner_id = bob.id
    photo.caption = "Sunset over the lake"
    photo.image = File.open("#{Rails.root}/spec/support/kirb.gif")
    photo.save

    other_photo = Photo.new
    other_photo.owner_id = bob.id
    other_photo.caption = "Pancakes for dinner"
    other_photo.image = File.open("#{Rails.root}/spec/support/kirb.gif")
    other_photo.save

    first_comment = Comment.new
    first_comment.author_id = dave.id
    first_comment.photo_id = photo.id
    first_comment.body = "What a view"
    first_comment.save

    other_comment = Comment.new
    other_comment.author_id = dave.id
    other_comment.photo_id = other_photo.id
    other_comment.body = "Save me a plate"
    other_comment.save

    visit "/users/sign_in"

    fill_in "Email", with: alice.email
    fill_in "Password", with: alice.password
    click_button "Log in"

    visit "/photos/#{photo.id}"

    expect(page).to have_text("What a view"),
      "Expected to find the comment 'What a view', but didn't."
    expect(page).to have_text("dave"),
      "Expected to find the username of the comment's author, 'dave', but didn't."
    expect(page).to_not have_text("Save me a plate"),
      "Expected not to find the comment 'Save me a plate', which is on a different photo, but found it."
  end
end

describe "/insert_like" do
  it "likes the photo on behalf of the signed-in user", points: 1, hint: h("current_user_owner") do
    alice = User.new
    alice.email = "alice@example.com"
    alice.password = "password"
    alice.username = "alice"
    alice.private = false
    alice.save

    bob = User.new
    bob.email = "bob@example.com"
    bob.password = "password"
    bob.username = "bob"
    bob.private = false
    bob.save

    photo = Photo.new
    photo.owner_id = bob.id
    photo.caption = "Sunset over the lake"
    photo.image = File.open("#{Rails.root}/spec/support/kirb.gif")
    photo.save

    visit "/users/sign_in"

    fill_in "Email", with: alice.email
    fill_in "Password", with: alice.password
    click_button "Log in"

    visit "/photos/#{photo.id}"
    click_button "Like"

    matching_likes = Like.where({ :fan_id => alice.id, :photo_id => photo.id })

    expect(matching_likes.count).to eq(1),
      "Expected clicking 'Like' to add one like with the signed-in user's ID in fan_id and the photo's ID in photo_id, but found #{matching_likes.count}."
  end
end

describe "/photos/[ID]" do
  it "has an 'Unlike' link in place of the 'Like' button once the user has liked the photo", points: 1 do
    alice = User.new
    alice.email = "alice@example.com"
    alice.password = "password"
    alice.username = "alice"
    alice.private = false
    alice.save

    bob = User.new
    bob.email = "bob@example.com"
    bob.password = "password"
    bob.username = "bob"
    bob.private = false
    bob.save

    photo = Photo.new
    photo.owner_id = bob.id
    photo.caption = "Sunset over the lake"
    photo.image = File.open("#{Rails.root}/spec/support/kirb.gif")
    photo.save

    the_like = Like.new
    the_like.fan_id = alice.id
    the_like.photo_id = photo.id
    the_like.save

    visit "/users/sign_in"

    fill_in "Email", with: alice.email
    fill_in "Password", with: alice.password
    click_button "Log in"

    visit "/photos/#{photo.id}"

    expect(page).to have_link("Unlike"),
      "Expected to find a link with the text 'Unlike', but didn't find one."
    expect(page).to_not have_button("Like", exact: true),
      "Expected not to find a 'Like' button on a photo that the user has already liked, but found one."
  end
end

describe "/delete_like/[ID]" do
  it "removes the signed-in user's like", points: 1 do
    alice = User.new
    alice.email = "alice@example.com"
    alice.password = "password"
    alice.username = "alice"
    alice.private = false
    alice.save

    bob = User.new
    bob.email = "bob@example.com"
    bob.password = "password"
    bob.username = "bob"
    bob.private = false
    bob.save

    photo = Photo.new
    photo.owner_id = bob.id
    photo.caption = "Sunset over the lake"
    photo.image = File.open("#{Rails.root}/spec/support/kirb.gif")
    photo.save

    the_like = Like.new
    the_like.fan_id = alice.id
    the_like.photo_id = photo.id
    the_like.save

    visit "/users/sign_in"

    fill_in "Email", with: alice.email
    fill_in "Password", with: alice.password
    click_button "Log in"

    visit "/photos/#{photo.id}"
    click_link "Unlike"

    matching_likes = Like.where({ :fan_id => alice.id, :photo_id => photo.id })

    expect(matching_likes.count).to eq(0),
      "Expected clicking 'Unlike' to delete the signed-in user's like, but it's still there."
  end
end

describe "/delete_like/[ID]" do
  it "does not remove another user's like", points: 2, hint: h("only_your_own") do
    alice = User.new
    alice.email = "alice@example.com"
    alice.password = "password"
    alice.username = "alice"
    alice.private = false
    alice.save

    bob = User.new
    bob.email = "bob@example.com"
    bob.password = "password"
    bob.username = "bob"
    bob.private = false
    bob.save

    dave = User.new
    dave.email = "dave@example.com"
    dave.password = "password"
    dave.username = "dave"
    dave.private = false
    dave.save

    photo = Photo.new
    photo.owner_id = bob.id
    photo.caption = "Sunset over the lake"
    photo.image = File.open("#{Rails.root}/spec/support/kirb.gif")
    photo.save

    daves_like = Like.new
    daves_like.fan_id = dave.id
    daves_like.photo_id = photo.id
    daves_like.save

    visit "/users/sign_in"

    fill_in "Email", with: alice.email
    fill_in "Password", with: alice.password
    click_button "Log in"

    visit "/delete_like/#{daves_like.id}"

    matching_likes = Like.where({ :id => daves_like.id })

    expect(matching_likes.count).to eq(1),
      "Expected a like to survive when a different user visits its delete URL, but it was deleted."
  end
end

describe "/insert_comment" do
  it "adds a comment by the signed-in user to the photo", points: 1, hint: h("label_for_input current_user_owner") do
    alice = User.new
    alice.email = "alice@example.com"
    alice.password = "password"
    alice.username = "alice"
    alice.private = false
    alice.save

    bob = User.new
    bob.email = "bob@example.com"
    bob.password = "password"
    bob.username = "bob"
    bob.private = false
    bob.save

    photo = Photo.new
    photo.owner_id = bob.id
    photo.caption = "Sunset over the lake"
    photo.image = File.open("#{Rails.root}/spec/support/kirb.gif")
    photo.save

    visit "/users/sign_in"

    fill_in "Email", with: alice.email
    fill_in "Password", with: alice.password
    click_button "Log in"

    visit "/photos/#{photo.id}"

    fill_in "Comment", with: "What a view"
    click_button "Add comment"

    matching_comments = Comment.where({ :author_id => alice.id, :photo_id => photo.id, :body => "What a view" })

    expect(matching_comments.count).to eq(1),
      "Expected clicking 'Add comment' to add one comment with the signed-in user's ID in author_id and the photo's ID in photo_id, but found #{matching_comments.count}."
  end
end

describe "/photos/[ID]" do
  it "has a form to update the photo and a link to delete it when it belongs to the signed-in user", points: 1 do
    alice = User.new
    alice.email = "alice@example.com"
    alice.password = "password"
    alice.username = "alice"
    alice.private = false
    alice.save

    photo = Photo.new
    photo.owner_id = alice.id
    photo.caption = "Sunset over the lake"
    photo.image = File.open("#{Rails.root}/spec/support/kirb.gif")
    photo.save

    visit "/users/sign_in"

    fill_in "Email", with: alice.email
    fill_in "Password", with: alice.password
    click_button "Log in"

    visit "/photos/#{photo.id}"

    expect(page).to have_css("form[action='/modify_photo/#{photo.id}']"),
      "Expected to find a <form> whose action is '/modify_photo/#{photo.id}', but didn't find one."
    expect(page).to have_button("Update photo"),
      "Expected to find a <button> with the text 'Update photo', but didn't find one."
    expect(page).to have_link("Delete this photo"),
      "Expected to find a link with the text 'Delete this photo', but didn't find one."
  end
end

describe "/photos/[ID]" do
  it "has neither when the photo belongs to someone else", points: 1 do
    alice = User.new
    alice.email = "alice@example.com"
    alice.password = "password"
    alice.username = "alice"
    alice.private = false
    alice.save

    bob = User.new
    bob.email = "bob@example.com"
    bob.password = "password"
    bob.username = "bob"
    bob.private = false
    bob.save

    photo = Photo.new
    photo.owner_id = bob.id
    photo.caption = "Sunset over the lake"
    photo.image = File.open("#{Rails.root}/spec/support/kirb.gif")
    photo.save

    visit "/users/sign_in"

    fill_in "Email", with: alice.email
    fill_in "Password", with: alice.password
    click_button "Log in"

    visit "/photos/#{photo.id}"

    expect(page).to_not have_button("Update photo"),
      "Expected not to find an 'Update photo' button on someone else's photo, but found one."
    expect(page).to_not have_link("Delete this photo"),
      "Expected not to find a 'Delete this photo' link on someone else's photo, but found one."
  end
end

describe "/modify_photo/[ID]" do
  it "updates the caption of the signed-in user's photo", points: 1, hint: h("optional_image") do
    alice = User.new
    alice.email = "alice@example.com"
    alice.password = "password"
    alice.username = "alice"
    alice.private = false
    alice.save

    photo = Photo.new
    photo.owner_id = alice.id
    photo.caption = "Sunset over the lake"
    photo.image = File.open("#{Rails.root}/spec/support/kirb.gif")
    photo.save

    visit "/users/sign_in"

    fill_in "Email", with: alice.email
    fill_in "Password", with: alice.password
    click_button "Log in"

    visit "/photos/#{photo.id}"

    within("form[action='/modify_photo/#{photo.id}']") do
      fill_in "Caption", with: "Sunrise, actually"
      click_button "Update photo"
    end

    updated_photo = Photo.where({ :id => photo.id }).at(0)

    expect(updated_photo.caption).to eq("Sunrise, actually"),
      "Expected the caption to change to 'Sunrise, actually', but it was #{updated_photo.caption.inspect}."
  end
end

describe "/modify_photo/[ID]" do
  it "does not update another user's photo", points: 2, hint: h("only_your_own") do
    alice = User.new
    alice.email = "alice@example.com"
    alice.password = "password"
    alice.username = "alice"
    alice.private = false
    alice.save

    bob = User.new
    bob.email = "bob@example.com"
    bob.password = "password"
    bob.username = "bob"
    bob.private = false
    bob.save

    photo = Photo.new
    photo.owner_id = bob.id
    photo.caption = "Sunset over the lake"
    photo.image = File.open("#{Rails.root}/spec/support/kirb.gif")
    photo.save

    visit "/users/sign_in"

    fill_in "Email", with: alice.email
    fill_in "Password", with: alice.password
    click_button "Log in"

    page.driver.post("/modify_photo/#{photo.id}", { "caption_param" => "Changed by someone else", "query_caption" => "Changed by someone else" })

    unchanged_photo = Photo.where({ :id => photo.id }).at(0)

    expect(unchanged_photo.caption).to eq("Sunset over the lake"),
      "Expected a photo's caption to stay the same when a different user submits a change to it, but it became #{unchanged_photo.caption.inspect}."
  end
end

describe "/delete_photo/[ID]" do
  it "deletes the signed-in user's photo", points: 1 do
    alice = User.new
    alice.email = "alice@example.com"
    alice.password = "password"
    alice.username = "alice"
    alice.private = false
    alice.save

    photo = Photo.new
    photo.owner_id = alice.id
    photo.caption = "Sunset over the lake"
    photo.image = File.open("#{Rails.root}/spec/support/kirb.gif")
    photo.save

    visit "/users/sign_in"

    fill_in "Email", with: alice.email
    fill_in "Password", with: alice.password
    click_button "Log in"

    visit "/photos/#{photo.id}"
    click_link "Delete this photo"

    matching_photos = Photo.where({ :id => photo.id })

    expect(matching_photos.count).to eq(0),
      "Expected clicking 'Delete this photo' to delete the photo, but it's still there."
  end
end

describe "/delete_photo/[ID]" do
  it "does not delete another user's photo", points: 2, hint: h("only_your_own") do
    alice = User.new
    alice.email = "alice@example.com"
    alice.password = "password"
    alice.username = "alice"
    alice.private = false
    alice.save

    bob = User.new
    bob.email = "bob@example.com"
    bob.password = "password"
    bob.username = "bob"
    bob.private = false
    bob.save

    photo = Photo.new
    photo.owner_id = bob.id
    photo.caption = "Sunset over the lake"
    photo.image = File.open("#{Rails.root}/spec/support/kirb.gif")
    photo.save

    visit "/users/sign_in"

    fill_in "Email", with: alice.email
    fill_in "Password", with: alice.password
    click_button "Log in"

    visit "/delete_photo/#{photo.id}"

    matching_photos = Photo.where({ :id => photo.id })

    expect(matching_photos.count).to eq(1),
      "Expected a photo to survive when a different user visits its delete URL, but it was deleted."
  end
end

describe "/photos/[ID]" do
  it "does not display a private user's photo to someone who doesn't follow them", points: 2, hint: h("private_photos") do
    alice = User.new
    alice.email = "alice@example.com"
    alice.password = "password"
    alice.username = "alice"
    alice.private = false
    alice.save

    carol = User.new
    carol.email = "carol@example.com"
    carol.password = "password"
    carol.username = "carol"
    carol.private = true
    carol.save

    photo = Photo.new
    photo.owner_id = carol.id
    photo.caption = "For my followers only"
    photo.image = File.open("#{Rails.root}/spec/support/kirb.gif")
    photo.save

    visit "/users/sign_in"

    fill_in "Email", with: alice.email
    fill_in "Password", with: alice.password
    click_button "Log in"

    visit "/photos/#{photo.id}"

    expect(page).to_not have_text("For my followers only"),
      "Expected not to find the caption of a private user's photo when signed in as someone who doesn't follow them, but found it."
  end
end

describe "/photos/[ID]" do
  it "does not display a private user's photo while the follow request is still pending", points: 1, hint: h("private_photos accepted_only") do
    alice = User.new
    alice.email = "alice@example.com"
    alice.password = "password"
    alice.username = "alice"
    alice.private = false
    alice.save

    carol = User.new
    carol.email = "carol@example.com"
    carol.password = "password"
    carol.username = "carol"
    carol.private = true
    carol.save

    photo = Photo.new
    photo.owner_id = carol.id
    photo.caption = "For my followers only"
    photo.image = File.open("#{Rails.root}/spec/support/kirb.gif")
    photo.save

    follow_request = FollowRequest.new
    follow_request.sender_id = alice.id
    follow_request.recipient_id = carol.id
    follow_request.status = "pending"
    follow_request.save

    visit "/users/sign_in"

    fill_in "Email", with: alice.email
    fill_in "Password", with: alice.password
    click_button "Log in"

    visit "/photos/#{photo.id}"

    expect(page).to_not have_text("For my followers only"),
      "Expected not to find the caption of a private user's photo while the signed-in user's follow request is pending, but found it."
  end
end

describe "/photos/[ID]" do
  it "displays a private user's photo to a follower they have accepted", points: 1, hint: h("private_photos") do
    alice = User.new
    alice.email = "alice@example.com"
    alice.password = "password"
    alice.username = "alice"
    alice.private = false
    alice.save

    carol = User.new
    carol.email = "carol@example.com"
    carol.password = "password"
    carol.username = "carol"
    carol.private = true
    carol.save

    photo = Photo.new
    photo.owner_id = carol.id
    photo.caption = "For my followers only"
    photo.image = File.open("#{Rails.root}/spec/support/kirb.gif")
    photo.save

    follow_request = FollowRequest.new
    follow_request.sender_id = alice.id
    follow_request.recipient_id = carol.id
    follow_request.status = "accepted"
    follow_request.save

    visit "/users/sign_in"

    fill_in "Email", with: alice.email
    fill_in "Password", with: alice.password
    click_button "Log in"

    visit "/photos/#{photo.id}"

    expect(page).to have_text("For my followers only"),
      "Expected to find the caption of a private user's photo when signed in as a follower they accepted, but didn't."
  end
end
