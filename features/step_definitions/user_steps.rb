Given /^no user exists with an email of "(.*)"$/ do |email|
  User.find(:first, :conditions => { :email => email }).should be_nil
end

Given /^I am logged in as an admin$/ do
  user = Factory.build(:admin_user)
  Given %{I sign in as "#{user.email}/#{user.password}"}
end

Given /^I am logged in as an approved user$/ do
  user = Factory.build(:approved_user)
  Given %{I sign in as "#{user.email}/#{user.password}"}
end

Then /^I should be already signed in$/ do
  visit root_path
  And %{I should see "Logout"}
end

Given /^I am signed up as "(.*)\/(.*)"$/ do |email, password|
  Given %{I am not logged in}
  When %{I go to the sign up page}
  And %{I fill in "Email" with "#{email}"}
  And %{I fill in "Password" with "#{password}"}
  And %{I fill in "Password confirmation" with "#{password}"}
  And %{I press "Sign up"}
  Then %{I should see "You have signed up successfully. If enabled, a confirmation was sent to your e-mail."}
  And %{I am logged out}
end

Then /^I sign out$/ do
  visit root_path
  click_link "Logout" if page.has_content?('Logout')
end

Given /^I am logged out$/ do
  Given %{I sign out}
end

Given /^I am not logged in$/ do
  Given %{I sign out}
end

When /^I sign in as "(.*)\/(.*)"$/ do |email, password|
  Given %{I am not logged in}
  When %{I go to the sign in page}
  And %{I fill in "Email" with "#{email}"}
  And %{I fill in "Password" with "#{password}"}
  And %{I press "Sign in"}
end

Then /^I should be signed in$/ do
  visit root_path
  And %{I should see "Logout"}
  And %{I should not see "Login"}
end

When /^I return next time$/ do
  And %{I go to the home page}
end

Then /^I should be signed out$/ do
  visit root_path
  And %{I should see "Login"}
  And %{I should see "Register to Join the GLATOS Network"}
  And %{I should not see "Logout"}
end
