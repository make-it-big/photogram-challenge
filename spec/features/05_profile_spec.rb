require "rails_helper"

describe "/users/[USERNAME]" do
  it "sends a visitor who isn't signed in to the sign-in page", points: 1, hint: h("require_sign_in") do
    bob = User.new
    bob.email = "bob@example.com"
    bob.password = "password"
    bob.username = "bob"
    bob.private = false
    bob.save

    visit "/users/bob"

    expect(page).to have_current_path("/users/sign_in"),
      "Expected to be redirected to '/users/sign_in' when not signed in, but ended up at '#{page.current_path}'."
  end
end

describe "/users/[USERNAME]" do
  it "displays the number of followers, counting only accepted follow requests", points: 1, hint: h("accepted_only count_rows") do
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
    bob.private = true
    bob.save

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
    erin.private = false
    erin.save

    frank = User.new
    frank.email = "frank@example.com"
    frank.password = "password"
    frank.username = "frank"
    frank.private = false
    frank.save

    first_request = FollowRequest.new
    first_request.sender_id = alice.id
    first_request.recipient_id = bob.id
    first_request.status = "accepted"
    first_request.save

    second_request = FollowRequest.new
    second_request.sender_id = dave.id
    second_request.recipient_id = bob.id
    second_request.status = "accepted"
    second_request.save

    third_request = FollowRequest.new
    third_request.sender_id = erin.id
    third_request.recipient_id = bob.id
    third_request.status = "pending"
    third_request.save

    fourth_request = FollowRequest.new
    fourth_request.sender_id = frank.id
    fourth_request.recipient_id = bob.id
    fourth_request.status = "rejected"
    fourth_request.save

    visit "/users/sign_in"

    fill_in "Email", with: alice.email
    fill_in "Password", with: alice.password
    click_button "Log in"

    visit "/users/bob"

    expect(page).to have_text("2 followers"),
      "Expected a user with two accepted requests, one pending, and one rejected to say '2 followers', but didn't find that."
  end
end

describe "/users/[USERNAME]" do
  it "displays the number of users that the user is following, counting only accepted follow requests", points: 1, hint: h("accepted_only count_rows") do
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

    erin = User.new
    erin.email = "erin@example.com"
    erin.password = "password"
    erin.username = "erin"
    erin.private = true
    erin.save

    first_request = FollowRequest.new
    first_request.sender_id = bob.id
    first_request.recipient_id = alice.id
    first_request.status = "accepted"
    first_request.save

    second_request = FollowRequest.new
    second_request.sender_id = bob.id
    second_request.recipient_id = dave.id
    second_request.status = "accepted"
    second_request.save

    third_request = FollowRequest.new
    third_request.sender_id = bob.id
    third_request.recipient_id = erin.id
    third_request.status = "pending"
    third_request.save

    visit "/users/sign_in"

    fill_in "Email", with: alice.email
    fill_in "Password", with: alice.password
    click_button "Log in"

    visit "/users/bob"

    expect(page).to have_text("2 following"),
      "Expected a user who sent two accepted requests and one pending request to say '2 following', but didn't find that."
  end
end

describe "/users/[USERNAME]" do
  it "displays the user's own photos, linked to their details pages, and nobody else's", points: 1 do
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

    bobs_photo = Photo.new
    bobs_photo.owner_id = bob.id
    bobs_photo.caption = "Sunset over the lake"
    bobs_photo.image = File.open("#{Rails.root}/spec/support/kirb.gif")
    bobs_photo.save

    daves_photo = Photo.new
    daves_photo.owner_id = dave.id
    daves_photo.caption = "Pancakes for dinner"
    daves_photo.image = File.open("#{Rails.root}/spec/support/kirb.gif")
    daves_photo.save

    visit "/users/sign_in"

    fill_in "Email", with: alice.email
    fill_in "Password", with: alice.password
    click_button "Log in"

    visit "/users/bob"

    expect(page).to have_text("Sunset over the lake"),
      "Expected to find the caption of the user's photo, 'Sunset over the lake', but didn't."
    expect(page).to have_css("a[href='/photos/#{bobs_photo.id}']"),
      "Expected to find a link to '/photos/#{bobs_photo.id}', but didn't find one."
    expect(page).to_not have_text("Pancakes for dinner"),
      "Expected not to find 'Pancakes for dinner', which a different user posted, but found it."
  end
end

describe "/users/[USERNAME]" do
  it "displays the photos that the user has liked", points: 1, hint: h("liked_photos") do
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

    daves_photo = Photo.new
    daves_photo.owner_id = dave.id
    daves_photo.caption = "Pancakes for dinner"
    daves_photo.image = File.open("#{Rails.root}/spec/support/kirb.gif")
    daves_photo.save

    bobs_like = Like.new
    bobs_like.fan_id = bob.id
    bobs_like.photo_id = daves_photo.id
    bobs_like.save

    visit "/users/sign_in"

    fill_in "Email", with: alice.email
    fill_in "Password", with: alice.password
    click_button "Log in"

    visit "/users/bob"

    expect(page).to have_text("Pancakes for dinner"),
      "Expected to find the caption of a photo that the user liked, 'Pancakes for dinner', but didn't."
  end
end

describe "/insert_follow_request" do
  it "follows a public user right away", points: 1, hint: h("follow_status current_user_owner") do
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

    visit "/users/sign_in"

    fill_in "Email", with: alice.email
    fill_in "Password", with: alice.password
    click_button "Log in"

    visit "/users/bob"
    click_button "Follow"

    the_request = FollowRequest.where({ :sender_id => alice.id, :recipient_id => bob.id }).at(0)

    expect(the_request).to_not be_nil,
      "Expected clicking 'Follow' to add a follow request from the signed-in user to this user, but didn't find one."
    expect(the_request.status).to eq("accepted"),
      "Expected a request to a public user to have the status 'accepted', but it was #{the_request.status.inspect}."
  end
end

describe "/insert_follow_request" do
  it "sends a pending request to a private user", points: 2, hint: h("follow_status") do
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

    visit "/users/sign_in"

    fill_in "Email", with: alice.email
    fill_in "Password", with: alice.password
    click_button "Log in"

    visit "/users/carol"
    click_button "Follow"

    the_request = FollowRequest.where({ :sender_id => alice.id, :recipient_id => carol.id }).at(0)

    expect(the_request).to_not be_nil,
      "Expected clicking 'Follow' to add a follow request from the signed-in user to this user, but didn't find one."
    expect(the_request.status).to eq("pending"),
      "Expected a request to a private user to have the status 'pending', but it was #{the_request.status.inspect}."
  end
end

describe "/insert_follow_request" do
  it "does not let a user follow themselves", points: 1, hint: h("no_self_follow") do
    alice = User.new
    alice.email = "alice@example.com"
    alice.password = "password"
    alice.username = "alice"
    alice.private = false
    alice.save

    visit "/users/sign_in"

    fill_in "Email", with: alice.email
    fill_in "Password", with: alice.password
    click_button "Log in"

    page.driver.post("/insert_follow_request", { "recipient_id_param" => alice.id, "query_recipient_id" => alice.id })

    matching_requests = FollowRequest.where({ :sender_id => alice.id, :recipient_id => alice.id })

    expect(matching_requests.count).to eq(0),
      "Expected no follow request from a user to themselves, but found #{matching_requests.count}."
  end
end

describe "/users/[USERNAME]" do
  it "has an 'Edit profile' link and no 'Follow' button on the signed-in user's own profile", points: 1 do
    alice = User.new
    alice.email = "alice@example.com"
    alice.password = "password"
    alice.username = "alice"
    alice.private = false
    alice.save

    visit "/users/sign_in"

    fill_in "Email", with: alice.email
    fill_in "Password", with: alice.password
    click_button "Log in"

    visit "/users/alice"

    expect(page).to have_link("Edit profile", href: "/users/edit"),
      "Expected to find a link with the text 'Edit profile' to '/users/edit', but didn't find one."
    expect(page).to_not have_button("Follow"),
      "Expected not to find a 'Follow' button on your own profile, but found one."
  end
end

describe "/users/[USERNAME]" do
  it "has an 'Unfollow' link in place of the 'Follow' button when the signed-in user follows the user", points: 1 do
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

    visit "/users/sign_in"

    fill_in "Email", with: alice.email
    fill_in "Password", with: alice.password
    click_button "Log in"

    visit "/users/bob"

    expect(page).to have_link("Unfollow"),
      "Expected to find a link with the text 'Unfollow', but didn't find one."
    expect(page).to_not have_button("Follow"),
      "Expected not to find a 'Follow' button for a user that the signed-in user already follows, but found one."
  end
end

describe "/delete_follow_request/[ID]" do
  it "unfollows the user", points: 1 do
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

    visit "/users/sign_in"

    fill_in "Email", with: alice.email
    fill_in "Password", with: alice.password
    click_button "Log in"

    visit "/users/bob"
    click_link "Unfollow"

    matching_requests = FollowRequest.where({ :id => follow_request.id })

    expect(matching_requests.count).to eq(0),
      "Expected clicking 'Unfollow' to delete the follow request, but it's still there."
  end
end

describe "/users/[USERNAME]" do
  it "says 'Request sent' and has a 'Cancel' link while the signed-in user's request is pending", points: 1, hint: h("copy_must_match") do
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

    follow_request = FollowRequest.new
    follow_request.sender_id = alice.id
    follow_request.recipient_id = carol.id
    follow_request.status = "pending"
    follow_request.save

    visit "/users/sign_in"

    fill_in "Email", with: alice.email
    fill_in "Password", with: alice.password
    click_button "Log in"

    visit "/users/carol"

    expect(page).to have_text("Request sent"),
      "Expected to find the text 'Request sent', but didn't."
    expect(page).to have_link("Cancel"),
      "Expected to find a link with the text 'Cancel', but didn't find one."
    expect(page).to_not have_button("Follow"),
      "Expected not to find a 'Follow' button for a user that the signed-in user has already asked to follow, but found one."
  end
end

describe "/delete_follow_request/[ID]" do
  it "cancels a pending request", points: 1 do
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

    follow_request = FollowRequest.new
    follow_request.sender_id = alice.id
    follow_request.recipient_id = carol.id
    follow_request.status = "pending"
    follow_request.save

    visit "/users/sign_in"

    fill_in "Email", with: alice.email
    fill_in "Password", with: alice.password
    click_button "Log in"

    visit "/users/carol"
    click_link "Cancel"

    matching_requests = FollowRequest.where({ :id => follow_request.id })

    expect(matching_requests.count).to eq(0),
      "Expected clicking 'Cancel' to delete the follow request, but it's still there."
  end
end

describe "/users/[USERNAME]" do
  it "says 'Request declined' when the user rejected the signed-in user's request", points: 1, hint: h("copy_must_match") do
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

    follow_request = FollowRequest.new
    follow_request.sender_id = alice.id
    follow_request.recipient_id = carol.id
    follow_request.status = "rejected"
    follow_request.save

    visit "/users/sign_in"

    fill_in "Email", with: alice.email
    fill_in "Password", with: alice.password
    click_button "Log in"

    visit "/users/carol"

    expect(page).to have_text("Request declined"),
      "Expected to find the text 'Request declined', but didn't."
    expect(page).to_not have_button("Follow"),
      "Expected not to find a 'Follow' button for a user who rejected the signed-in user's request, but found one."
  end
end

describe "/delete_follow_request/[ID]" do
  it "does not delete a request that someone else sent", points: 2, hint: h("only_your_own") do
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

    follow_request = FollowRequest.new
    follow_request.sender_id = dave.id
    follow_request.recipient_id = bob.id
    follow_request.status = "accepted"
    follow_request.save

    visit "/users/sign_in"

    fill_in "Email", with: alice.email
    fill_in "Password", with: alice.password
    click_button "Log in"

    visit "/delete_follow_request/#{follow_request.id}"

    matching_requests = FollowRequest.where({ :id => follow_request.id })

    expect(matching_requests.count).to eq(1),
      "Expected a follow request to survive when a user who didn't send it visits its delete URL, but it was deleted."
  end
end

describe "/users/[USERNAME]" do
  it "lists the pending follow requests on the signed-in user's own profile", points: 1, hint: h("pending_requests") do
    alice = User.new
    alice.email = "alice@example.com"
    alice.password = "password"
    alice.username = "alice"
    alice.private = true
    alice.save

    bob = User.new
    bob.email = "bob@example.com"
    bob.password = "password"
    bob.username = "bob"
    bob.private = false
    bob.save

    follow_request = FollowRequest.new
    follow_request.sender_id = bob.id
    follow_request.recipient_id = alice.id
    follow_request.status = "pending"
    follow_request.save

    visit "/users/sign_in"

    fill_in "Email", with: alice.email
    fill_in "Password", with: alice.password
    click_button "Log in"

    visit "/users/alice"

    expect(page).to have_text("bob"),
      "Expected to find the username of the user who asked to follow, 'bob', but didn't."
    expect(page).to have_button("Accept"),
      "Expected to find a <button> with the text 'Accept', but didn't find one."
    expect(page).to have_button("Reject"),
      "Expected to find a <button> with the text 'Reject', but didn't find one."
  end
end

describe "/modify_follow_request/[ID]" do
  it "accepts a request when its recipient clicks 'Accept'", points: 1, hint: h("hidden_status") do
    alice = User.new
    alice.email = "alice@example.com"
    alice.password = "password"
    alice.username = "alice"
    alice.private = true
    alice.save

    bob = User.new
    bob.email = "bob@example.com"
    bob.password = "password"
    bob.username = "bob"
    bob.private = false
    bob.save

    follow_request = FollowRequest.new
    follow_request.sender_id = bob.id
    follow_request.recipient_id = alice.id
    follow_request.status = "pending"
    follow_request.save

    visit "/users/sign_in"

    fill_in "Email", with: alice.email
    fill_in "Password", with: alice.password
    click_button "Log in"

    visit "/users/alice"
    click_button "Accept"

    the_request = FollowRequest.where({ :id => follow_request.id }).at(0)

    expect(the_request.status).to eq("accepted"),
      "Expected clicking 'Accept' to change the request's status to 'accepted', but it was #{the_request.status.inspect}."
  end
end

describe "/modify_follow_request/[ID]" do
  it "rejects a request when its recipient clicks 'Reject'", points: 1, hint: h("hidden_status") do
    alice = User.new
    alice.email = "alice@example.com"
    alice.password = "password"
    alice.username = "alice"
    alice.private = true
    alice.save

    bob = User.new
    bob.email = "bob@example.com"
    bob.password = "password"
    bob.username = "bob"
    bob.private = false
    bob.save

    follow_request = FollowRequest.new
    follow_request.sender_id = bob.id
    follow_request.recipient_id = alice.id
    follow_request.status = "pending"
    follow_request.save

    visit "/users/sign_in"

    fill_in "Email", with: alice.email
    fill_in "Password", with: alice.password
    click_button "Log in"

    visit "/users/alice"
    click_button "Reject"

    the_request = FollowRequest.where({ :id => follow_request.id }).at(0)

    expect(the_request.status).to eq("rejected"),
      "Expected clicking 'Reject' to change the request's status to 'rejected', but it was #{the_request.status.inspect}."
  end
end

describe "/users/[USERNAME]" do
  it "does not show a user's pending follow requests to anyone else", points: 1 do
    alice = User.new
    alice.email = "alice@example.com"
    alice.password = "password"
    alice.username = "alice"
    alice.private = true
    alice.save

    bob = User.new
    bob.email = "bob@example.com"
    bob.password = "password"
    bob.username = "bob"
    bob.private = false
    bob.save

    follow_request = FollowRequest.new
    follow_request.sender_id = bob.id
    follow_request.recipient_id = alice.id
    follow_request.status = "pending"
    follow_request.save

    dave = User.new
    dave.email = "dave@example.com"
    dave.password = "password"
    dave.username = "dave"
    dave.private = false
    dave.save

    daves_request = FollowRequest.new
    daves_request.sender_id = dave.id
    daves_request.recipient_id = alice.id
    daves_request.status = "accepted"
    daves_request.save

    visit "/users/sign_in"

    fill_in "Email", with: dave.email
    fill_in "Password", with: dave.password
    click_button "Log in"

    visit "/users/alice"

    expect(page).to_not have_button("Accept"),
      "Expected not to find an 'Accept' button when looking at someone else's profile, but found one."
  end
end

describe "/modify_follow_request/[ID]" do
  it "does not let anyone but the recipient accept a request", points: 2, hint: h("only_your_own") do
    alice = User.new
    alice.email = "alice@example.com"
    alice.password = "password"
    alice.username = "alice"
    alice.private = true
    alice.save

    bob = User.new
    bob.email = "bob@example.com"
    bob.password = "password"
    bob.username = "bob"
    bob.private = false
    bob.save

    follow_request = FollowRequest.new
    follow_request.sender_id = bob.id
    follow_request.recipient_id = alice.id
    follow_request.status = "pending"
    follow_request.save

    visit "/users/sign_in"

    fill_in "Email", with: bob.email
    fill_in "Password", with: bob.password
    click_button "Log in"

    page.driver.post("/modify_follow_request/#{follow_request.id}", { "status_param" => "accepted", "query_status" => "accepted" })

    the_request = FollowRequest.where({ :id => follow_request.id }).at(0)

    expect(the_request.status).to eq("pending"),
      "Expected a request to stay 'pending' when its sender tries to accept it themselves, but its status became #{the_request.status.inspect}."
  end
end

describe "/users/[USERNAME]" do
  it "does not display a private user's photos to someone who doesn't follow them, but still has the 'Follow' button", points: 2, hint: h("private_photos") do
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

    visit "/users/carol"

    expect(page).to have_current_path("/users/carol"),
      "Expected a private user's profile to be visible to any signed-in user, but ended up at '#{page.current_path}'."
    expect(page).to have_button("Follow"),
      "Expected to find a 'Follow' button on a private user's profile, but didn't find one."
    expect(page).to_not have_text("For my followers only"),
      "Expected not to find the caption of a private user's photo when signed in as someone who doesn't follow them, but found it."
  end
end

describe "/users/[USERNAME]" do
  it "displays a private user's photos to a follower they have accepted", points: 1, hint: h("private_photos") do
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

    visit "/users/carol"

    expect(page).to have_text("For my followers only"),
      "Expected to find the caption of a private user's photo when signed in as a follower they accepted, but didn't."
  end
end

describe "/users/[USERNAME]" do
  it "displays a private user's photos on their own profile", points: 1, hint: h("private_photos") do
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

    fill_in "Email", with: carol.email
    fill_in "Password", with: carol.password
    click_button "Log in"

    visit "/users/carol"

    expect(page).to have_text("For my followers only"),
      "Expected a private user to find the caption of their own photo on their profile, but didn't."
  end
end

describe "/users/[USERNAME]" do
  it "does not display a liked photo that the signed-in user isn't allowed to see", points: 2, hint: h("private_everywhere") do
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

    bob = User.new
    bob.email = "bob@example.com"
    bob.password = "password"
    bob.username = "bob"
    bob.private = false
    bob.save

    bobs_request = FollowRequest.new
    bobs_request.sender_id = bob.id
    bobs_request.recipient_id = carol.id
    bobs_request.status = "accepted"
    bobs_request.save

    bobs_like = Like.new
    bobs_like.fan_id = bob.id
    bobs_like.photo_id = photo.id
    bobs_like.save

    visit "/users/sign_in"

    fill_in "Email", with: alice.email
    fill_in "Password", with: alice.password
    click_button "Log in"

    visit "/users/bob"

    expect(page).to_not have_text("For my followers only"),
      "Expected not to find the caption of a private user's photo among another user's liked photos, when signed in as someone who doesn't follow the private user, but found it."
  end
end
