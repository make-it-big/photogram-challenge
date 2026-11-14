require "rails_helper"

describe "/users/sign_up" do
  it "lets a visitor sign up with a username", points: 1, hint: h("devise_views permit_fields") do
    visit "/users/sign_up"

    fill_in "Email", with: "pat@example.com"
    fill_in "Username", with: "pat"
    fill_in "Password", with: "password"
    fill_in "Password confirmation", with: "password"
    click_button "Sign up"

    new_user = User.where({ :email => "pat@example.com" }).at(0)

    expect(new_user).to_not be_nil,
      "Expected signing up to add a row to the users table, but there's no user with the email 'pat@example.com'."
    expect(new_user.username).to eq("pat"),
      "Expected the new user's username to be 'pat', but it was #{new_user.username.inspect}."
  end
end

describe "/users/sign_up" do
  it "lets a visitor sign up for a private account", points: 1, hint: h("private_checkbox permit_fields") do
    visit "/users/sign_up"

    fill_in "Email", with: "pat@example.com"
    fill_in "Username", with: "pat"
    fill_in "Password", with: "password"
    fill_in "Password confirmation", with: "password"
    check "Private"
    click_button "Sign up"

    new_user = User.where({ :email => "pat@example.com" }).at(0)

    expect(new_user).to_not be_nil,
      "Expected signing up to add a row to the users table, but there's no user with the email 'pat@example.com'."
    expect(new_user.private).to eq(true),
      "Expected the new user's private column to be true after checking 'Private', but it was #{new_user.private.inspect}."
  end
end

describe "/users/sign_in" do
  it "signs a user in and displays a notice", points: 1, hint: h("flash_messages") do
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

    expect(page).to have_text("Signed in successfully"),
      "Expected to see the notice 'Signed in successfully.' after signing in, but didn't find it."
  end
end

describe "/users/edit" do
  it "lets the signed-in user change their username", points: 1, hint: h("devise_views permit_fields") do
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

    visit "/users/edit"

    fill_in "Username", with: "alice_in_chains"
    fill_in "Current password", with: alice.password
    click_button "Update"

    updated_user = User.where({ :id => alice.id }).at(0)

    expect(updated_user.username).to eq("alice_in_chains"),
      "Expected the username to change to 'alice_in_chains', but it was #{updated_user.username.inspect}."
  end
end

describe "/" do
  it "has links to sign in and sign up when nobody is signed in", points: 1 do
    visit "/"

    expect(page).to have_link("Sign in", href: "/users/sign_in"),
      "Expected to find a link with the text 'Sign in' to '/users/sign_in', but didn't find one."
    expect(page).to have_link("Sign up", href: "/users/sign_up"),
      "Expected to find a link with the text 'Sign up' to '/users/sign_up', but didn't find one."
  end
end

describe "/" do
  it "has a button to sign out when a user is signed in", points: 1, hint: h("sign_out_button") do
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

    visit "/"

    expect(page).to have_css("form[action='/users/sign_out'] button", text: "Sign out"),
      "Expected to find a <button> with the text 'Sign out' inside a <form> whose action is '/users/sign_out', but didn't find one."
  end
end

describe "/users/sign_out" do
  it "signs the user out and displays a notice", points: 1, hint: h("sign_out_button flash_messages") do
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

    visit "/"
    click_button "Sign out"

    expect(page).to have_text("Signed out successfully"),
      "Expected to see the notice 'Signed out successfully.' after clicking 'Sign out', but didn't find it."
  end
end

describe "/" do
  it "has links to the signed-in user's feed, discover page, and profile", points: 1 do
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

    visit "/"

    expect(page).to have_link(href: "/feed"),
      "Expected to find a link to '/feed' when signed in, but didn't find one."
    expect(page).to have_link(href: "/discover"),
      "Expected to find a link to '/discover' when signed in, but didn't find one."
    expect(page).to have_link(href: "/users/alice"),
      "Expected to find a link to the signed-in user's profile, '/users/alice', but didn't find one."
  end
end

describe "/feed" do
  it "sends a visitor who isn't signed in to the sign-in page, with an alert", points: 1, hint: h("require_sign_in flash_messages") do
    visit "/feed"

    expect(page).to have_current_path("/users/sign_in"),
      "Expected to be redirected to '/users/sign_in' when not signed in, but ended up at '#{page.current_path}'."
    expect(page).to have_text("You need to sign in or sign up before continuing"),
      "Expected to see the alert 'You need to sign in or sign up before continuing.', but didn't find it."
  end
end
