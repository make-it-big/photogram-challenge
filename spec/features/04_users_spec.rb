require "rails_helper"

describe "/users" do
  it "can be visited without signing in", points: 1, hint: h("skip_sign_in") do
    visit "/users"

    expect(page).to have_current_path("/users"),
      "Expected to stay on '/users' without signing in, but ended up at '#{page.current_path}'."
    expect(page.status_code).to eq(200),
      "Expected '/users' to load without signing in, but the response's status was #{page.status_code}."
  end
end

describe "/users" do
  it "displays each user's username, linked to their profile", points: 1 do
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

    visit "/users"

    expect(page).to have_css("a[href='/users/bob']", text: "bob"),
      "Expected to find a link containing the text 'bob' to '/users/bob', but didn't find one."
    expect(page).to have_css("a[href='/users/carol']", text: "carol"),
      "Expected to find a link containing the text 'carol' to '/users/carol', but didn't find one."
  end
end

describe "/users" do
  it "says whether each user is Private or Public", points: 1, hint: h("copy_must_match") do
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

    visit "/users"

    expect(page).to have_text("Public"),
      "Expected to find the word 'Public' for a user whose private column is false, but didn't."
    expect(page).to have_text("Private"),
      "Expected to find the word 'Private' for a user whose private column is true, but didn't."
  end
end
