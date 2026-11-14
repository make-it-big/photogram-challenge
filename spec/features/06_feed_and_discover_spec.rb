require "rails_helper"

describe "/feed" do
  it "displays the photos posted by the users that the signed-in user follows, and nobody else's", points: 3, hint: h("feed accepted_only") do
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

    carol = User.new
    carol.email = "carol@example.com"
    carol.password = "password"
    carol.username = "carol"
    carol.private = true
    carol.save

    dave = User.new
    dave.email = "dave@example.com"
    dave.password = "password"
    dave.username = "dave"
    dave.private = false
    dave.save

    erin = User.new
    erin.email = "erin@example.com"
    erin.password = "password"
    erin.username = "erin"
    erin.private = true
    erin.save

    accepted_request = FollowRequest.new
    accepted_request.sender_id = alice.id
    accepted_request.recipient_id = bob.id
    accepted_request.status = "accepted"
    accepted_request.save

    pending_request = FollowRequest.new
    pending_request.sender_id = alice.id
    pending_request.recipient_id = carol.id
    pending_request.status = "pending"
    pending_request.save

    rejected_request = FollowRequest.new
    rejected_request.sender_id = alice.id
    rejected_request.recipient_id = erin.id
    rejected_request.status = "rejected"
    rejected_request.save

    bobs_photo = Photo.new
    bobs_photo.owner_id = bob.id
    bobs_photo.caption = "Sunset over the lake"
    bobs_photo.image = File.open("#{Rails.root}/spec/support/kirb.gif")
    bobs_photo.save

    carols_photo = Photo.new
    carols_photo.owner_id = carol.id
    carols_photo.caption = "Pending request photo"
    carols_photo.image = File.open("#{Rails.root}/spec/support/kirb.gif")
    carols_photo.save

    daves_photo = Photo.new
    daves_photo.owner_id = dave.id
    daves_photo.caption = "Not following photo"
    daves_photo.image = File.open("#{Rails.root}/spec/support/kirb.gif")
    daves_photo.save

    erins_photo = Photo.new
    erins_photo.owner_id = erin.id
    erins_photo.caption = "Rejected request photo"
    erins_photo.image = File.open("#{Rails.root}/spec/support/kirb.gif")
    erins_photo.save

    visit "/users/sign_in"

    fill_in "Email", with: alice.email
    fill_in "Password", with: alice.password
    click_button "Log in"

    visit "/feed"

    expect(page).to have_text("Sunset over the lake"),
      "Expected to find 'Sunset over the lake', posted by a user that the signed-in user follows, but didn't."
    expect(page).to_not have_text("Pending request photo"),
      "Expected not to find 'Pending request photo', because the request to its owner is still pending, but found it."
    expect(page).to_not have_text("Rejected request photo"),
      "Expected not to find 'Rejected request photo', because its owner rejected the request, but found it."
    expect(page).to_not have_text("Not following photo"),
      "Expected not to find 'Not following photo', because the signed-in user doesn't follow its owner, but found it."
  end
end

describe "/feed" do
  it "lists the newest photos first", points: 1, hint: h("newest_first") do
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

    follow_request = FollowRequest.new
    follow_request.sender_id = alice.id
    follow_request.recipient_id = bob.id
    follow_request.status = "accepted"
    follow_request.save

    older_photo = Photo.new
    older_photo.owner_id = bob.id
    older_photo.caption = "Posted last week"
    older_photo.image = File.open("#{Rails.root}/spec/support/kirb.gif")
    older_photo.created_at = 7.days.ago
    older_photo.save

    newer_photo = Photo.new
    newer_photo.owner_id = bob.id
    newer_photo.caption = "Posted this morning"
    newer_photo.image = File.open("#{Rails.root}/spec/support/kirb.gif")
    newer_photo.created_at = 2.hours.ago
    newer_photo.save

    visit "/users/sign_in"

    fill_in "Email", with: alice.email
    fill_in "Password", with: alice.password
    click_button "Log in"

    visit "/feed"

    expect(page).to have_text("Posted last week"),
      "Expected to find the caption 'Posted last week', but didn't."
    expect(page).to have_text("Posted this morning"),
      "Expected to find the caption 'Posted this morning', but didn't."
    expect(page.text.index("Posted this morning")).to be < page.text.index("Posted last week"),
      "Expected the newer photo, 'Posted this morning', to come before the older one, 'Posted last week', but it came after."
  end
end

describe "/discover" do
  it "sends a visitor who isn't signed in to the sign-in page", points: 1, hint: h("require_sign_in") do
    visit "/discover"

    expect(page).to have_current_path("/users/sign_in"),
      "Expected to be redirected to '/users/sign_in' when not signed in, but ended up at '#{page.current_path}'."
  end
end

describe "/discover" do
  it "displays the photos liked by the users that the signed-in user follows, and no others", points: 3, hint: h("discover accepted_only") do
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

    carol = User.new
    carol.email = "carol@example.com"
    carol.password = "password"
    carol.username = "carol"
    carol.private = true
    carol.save

    dave = User.new
    dave.email = "dave@example.com"
    dave.password = "password"
    dave.username = "dave"
    dave.private = false
    dave.save

    accepted_request = FollowRequest.new
    accepted_request.sender_id = alice.id
    accepted_request.recipient_id = bob.id
    accepted_request.status = "accepted"
    accepted_request.save

    pending_request = FollowRequest.new
    pending_request.sender_id = alice.id
    pending_request.recipient_id = carol.id
    pending_request.status = "pending"
    pending_request.save

    first_photo = Photo.new
    first_photo.owner_id = dave.id
    first_photo.caption = "Liked by someone I follow"
    first_photo.image = File.open("#{Rails.root}/spec/support/kirb.gif")
    first_photo.save

    second_photo = Photo.new
    second_photo.owner_id = dave.id
    second_photo.caption = "Liked by a pending request"
    second_photo.image = File.open("#{Rails.root}/spec/support/kirb.gif")
    second_photo.save

    third_photo = Photo.new
    third_photo.owner_id = dave.id
    third_photo.caption = "Liked by nobody"
    third_photo.image = File.open("#{Rails.root}/spec/support/kirb.gif")
    third_photo.save

    bobs_like = Like.new
    bobs_like.fan_id = bob.id
    bobs_like.photo_id = first_photo.id
    bobs_like.save

    carols_like = Like.new
    carols_like.fan_id = carol.id
    carols_like.photo_id = second_photo.id
    carols_like.save

    visit "/users/sign_in"

    fill_in "Email", with: alice.email
    fill_in "Password", with: alice.password
    click_button "Log in"

    visit "/discover"

    expect(page).to have_text("Liked by someone I follow"),
      "Expected to find 'Liked by someone I follow', which a user that the signed-in user follows has liked, but didn't."
    expect(page).to_not have_text("Liked by a pending request"),
      "Expected not to find 'Liked by a pending request', because the request to the user who liked it is still pending, but found it."
    expect(page).to_not have_text("Liked by nobody"),
      "Expected not to find 'Liked by nobody', but found it."
  end
end

describe "/discover" do
  it "does not display a private user's photo that the signed-in user isn't allowed to see", points: 2, hint: h("private_everywhere") do
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

    carol = User.new
    carol.email = "carol@example.com"
    carol.password = "password"
    carol.username = "carol"
    carol.private = true
    carol.save

    alices_request = FollowRequest.new
    alices_request.sender_id = alice.id
    alices_request.recipient_id = bob.id
    alices_request.status = "accepted"
    alices_request.save

    bobs_request = FollowRequest.new
    bobs_request.sender_id = bob.id
    bobs_request.recipient_id = carol.id
    bobs_request.status = "accepted"
    bobs_request.save

    photo = Photo.new
    photo.owner_id = carol.id
    photo.caption = "For my followers only"
    photo.image = File.open("#{Rails.root}/spec/support/kirb.gif")
    photo.save

    bobs_like = Like.new
    bobs_like.fan_id = bob.id
    bobs_like.photo_id = photo.id
    bobs_like.save

    visit "/users/sign_in"

    fill_in "Email", with: alice.email
    fill_in "Password", with: alice.password
    click_button "Log in"

    visit "/discover"

    expect(page).to_not have_text("For my followers only"),
      "Expected not to find the caption of a private user's photo, which someone the signed-in user follows has liked, when the signed-in user doesn't follow the private user. But found it."
  end
end
