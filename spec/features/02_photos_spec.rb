require "rails_helper"

describe "/" do
  it "displays the public photos, just as /photos does", points: 1, hint: h("root_route") do
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

    visit "/"

    expect(page).to have_text("Sunset over the lake"),
      "Expected the homepage to display the caption 'Sunset over the lake', but didn't find it."
  end
end

describe "/photos" do
  it "can be visited without signing in", points: 1, hint: h("skip_sign_in") do
    visit "/photos"

    expect(page).to have_current_path("/photos"),
      "Expected to stay on '/photos' without signing in, but ended up at '#{page.current_path}'."
    expect(page.status_code).to eq(200),
      "Expected '/photos' to load without signing in, but the response's status was #{page.status_code}."
  end
end

describe "/photos" do
  it "displays the caption of each photo posted by a public user", points: 1 do
    bob = User.new
    bob.email = "bob@example.com"
    bob.password = "password"
    bob.username = "bob"
    bob.private = false
    bob.save

    first_photo = Photo.new
    first_photo.owner_id = bob.id
    first_photo.caption = "Sunset over the lake"
    first_photo.image = File.open("#{Rails.root}/spec/support/kirb.gif")
    first_photo.save

    second_photo = Photo.new
    second_photo.owner_id = bob.id
    second_photo.caption = "Pancakes for dinner"
    second_photo.image = File.open("#{Rails.root}/spec/support/kirb.gif")
    second_photo.save

    visit "/photos"

    expect(page).to have_text("Sunset over the lake"),
      "Expected to find the caption 'Sunset over the lake', but didn't."
    expect(page).to have_text("Pancakes for dinner"),
      "Expected to find the caption 'Pancakes for dinner', but didn't."
  end
end

describe "/photos" do
  it "does not display photos posted by private users", points: 2, hint: h("public_photos") do
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

    public_photo = Photo.new
    public_photo.owner_id = bob.id
    public_photo.caption = "Sunset over the lake"
    public_photo.image = File.open("#{Rails.root}/spec/support/kirb.gif")
    public_photo.save

    private_photo = Photo.new
    private_photo.owner_id = carol.id
    private_photo.caption = "For my followers only"
    private_photo.image = File.open("#{Rails.root}/spec/support/kirb.gif")
    private_photo.save

    visit "/photos"

    expect(page).to have_text("Sunset over the lake"),
      "Expected to find the caption 'Sunset over the lake', which a public user posted, but didn't."
    expect(page).to_not have_text("For my followers only"),
      "Expected not to find the caption 'For my followers only', because the user who posted it is private, but found it."
  end
end

describe "/photos" do
  it "displays each photo in an <img> element", points: 1, hint: h("real_image_uploads") do
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

    visit "/photos"

    expect(page).to have_css("img[src*='kirb.gif']"),
      "Expected to find an <img> whose src contains the uploaded file's name, 'kirb.gif', but didn't find one."
  end
end

describe "/photos" do
  it "links each photo to its details page", points: 1 do
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

    visit "/photos"

    expect(page).to have_css("a[href='/photos/#{photo.id}']"),
      "Expected to find a link to '/photos/#{photo.id}', but didn't find one."
  end
end

describe "/photos" do
  it "lists the newest photos first", points: 1, hint: h("newest_first") do
    bob = User.new
    bob.email = "bob@example.com"
    bob.password = "password"
    bob.username = "bob"
    bob.private = false
    bob.save

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

    visit "/photos"

    expect(page).to have_text("Posted last week"),
      "Expected to find the caption 'Posted last week', but didn't."
    expect(page).to have_text("Posted this morning"),
      "Expected to find the caption 'Posted this morning', but didn't."
    expect(page.text.index("Posted this morning")).to be < page.text.index("Posted last week"),
      "Expected the newer photo, 'Posted this morning', to come before the older one, 'Posted last week', but it came after."
  end
end

describe "/photos" do
  it "has a form to add a photo when a user is signed in", points: 1, hint: h("label_for_input real_image_uploads") do
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

    visit "/photos"

    expect(page).to have_css("form[action='/insert_photo']"),
      "Expected to find a <form> whose action is '/insert_photo', but didn't find one."

    within("form[action='/insert_photo']") do
      expect(page).to have_field("Image", type: "file"),
        "Expected the form to have an <input type='file'> with the label 'Image', but didn't find one."
      expect(page).to have_field("Caption"),
        "Expected the form to have an input with the label 'Caption', but didn't find one."
      expect(page).to have_button("Add photo"),
        "Expected the form to have a <button> with the text 'Add photo', but didn't find one."
    end
  end
end

describe "/photos" do
  it "does not have the form to add a photo when nobody is signed in", points: 1 do
    visit "/photos"

    expect(page.status_code).to eq(200),
      "Expected '/photos' to load without signing in, but the response's status was #{page.status_code}."
    expect(page).to_not have_css("form[action='/insert_photo']"),
      "Expected not to find the form for adding a photo when not signed in, but found it."
  end
end

describe "/insert_photo" do
  it "adds a photo that belongs to the signed-in user", points: 1, hint: h("current_user_owner") do
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

    visit "/photos"

    within("form[action='/insert_photo']") do
      attach_file "Image", "#{Rails.root}/spec/support/kirb.gif"
      fill_in "Caption", with: "Fresh off the camera"
      click_button "Add photo"
    end

    new_photos = Photo.where({ :caption => "Fresh off the camera", :owner_id => alice.id })

    expect(new_photos.count).to eq(1),
      "Expected submitting the form to add one photo with the caption 'Fresh off the camera' and the signed-in user's ID in owner_id, but found #{new_photos.count}."
  end
end

describe "/insert_photo" do
  it "stores the uploaded file, so that the photo's page can display it", points: 2, hint: h("real_image_uploads") do
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

    visit "/photos"

    within("form[action='/insert_photo']") do
      attach_file "Image", "#{Rails.root}/spec/support/kirb.gif"
      fill_in "Caption", with: "Fresh off the camera"
      click_button "Add photo"
    end

    new_photo = Photo.where({ :caption => "Fresh off the camera" }).at(0)

    expect(new_photo).to_not be_nil,
      "Expected submitting the form to add a photo with the caption 'Fresh off the camera', but didn't find one."

    visit "/photos/#{new_photo.id}"

    expect(page).to have_css("img[src*='kirb.gif']"),
      "Expected the new photo's page to have an <img> whose src contains the uploaded file's name, 'kirb.gif', but didn't find one."
  end
end
