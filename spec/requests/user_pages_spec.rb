require 'spec_helper'

describe "User pages" do
  subject { page }

  describe "signup page" do
    before { visit signup_path }
    it { should have_selector('h1',    text: 'Sign up') }
    it { should have_selector('title', text: full_title('Sign up')) }
  end

  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }
    let!(:mp1) { FactoryGirl.create(:micropost, content: "foo", user: user) }
    let!(:mp2) { FactoryGirl.create(:micropost, content: "bar", user: user) }
    before { visit user_path(user) }  

    it { should have_selector('h1', text: user.name) }
    it { should have_selector('title', text: user.name) }
    it { should have_content(mp1.content) }
    it { should have_content(mp2.content) }
    it { should have_content(user.microposts.count) }
    describe "follow/unfollow" do
      let(:other_user) { FactoryGirl.create(:user) }
      before { signin user }
      describe "following a user" do
        before { visit user_path(other_user) }
        it "should increment the followers count" do
          expect do
            click_button "Follow"
          end.to change(other_user.followers, :count).by(1)
        end
        it "should increment the followed_users count" do
          expect do
            click_button "Follow"
          end.to change(user.followed_users, :count).by(1)
        end
        describe "toggling the button" do
          before { click_button 'Follow' }
          it { should have_button('Unfollow') }
        end
      end
      describe "unfollowing a user" do
        before { 
          visit user_path(other_user)
          click_button 'Follow'
        }
        it "should decrement the followers count" do
          expect do
            click_button "Unfollow"
          end.to change(other_user.followers, :count).by(-1)
        end
        it "should decrement the followed_users count" do
          expect do
            click_button 'Unfollow'
          end.to change(user.followed_users, :count).by(-1)
        end
        describe "toggling the button" do
          before { click_button 'Unfollow' }
          it { should have_button('Follow') }
        end
      end
    end
  end

  describe "edit page" do
    let(:user) { FactoryGirl.create(:user) }
    before {
      signin(user)
      visit edit_user_path(user)
    }

    describe "page" do
      it { should have_selector('h1',    text: "Update your profile") }
      it { should have_selector('title', text: "Edit user") }
      it { should have_xpath("//a[@target='_blank' and @href='http://gravatar.com/emails']") }
    end

    describe "with invalid information" do
      before { click_button "Save changes" }

      it { should have_error_message }
    end

    describe "with valid information" do
      let(:new_name)  { "New Name" }
      let(:new_email) { "new@example.com" }
      before do
        fill_in "Name",             with: new_name
        fill_in "Email",            with: new_email
        fill_in "Password",         with: user.password
        fill_in "Confirmation", with: user.password
        click_button "Save changes"
      end

      it { should have_selector('title', text: new_name) }
      it { should have_success_message('Saved') }
      it { should have_link('Sign out', href: signout_path) }
      specify { user.reload.name.should  == new_name }
      specify { user.reload.email.should == new_email }
    end
  end

  describe "signup" do
    before { visit signup_path }
    let(:submit) { "Create my account" }

    describe "with invalid information" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end

      describe "after submission" do
        before { click_button submit }
        it { should have_selector('title', text: 'Sign up') }
        it { should have_selector('div#error_explanation') }

        it { should have_error_message }
      end
    end

    describe "with valid information" do
      let(:user) { FactoryGirl.build(:user) }
      before do
        fill_in "Name",         with: user.name
        fill_in "Email",        with: user.email
        fill_in "Password",     with: user.password
        fill_in "Confirmation", with: user.password_confirmation
      end

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe "after saving a user" do
        before { click_button submit }
        it { should have_selector('title', text: user.name) }
        it { should have_success_message('Welcome') }
        it { should have_link('Sign out')}

        describe "navigate to home page" do
          before { click_link 'Home' }
          it {should_not have_link('Sign up now!') }
        end

        describe "followed by sign out" do
          before { click_link 'Sign out' }
          it { should have_link('Sign in') }
        end
      end
    end
  end
  describe "index page" do
    let(:user) { FactoryGirl.create(:user) }

    before(:each) do
      signin(user)
      visit users_path
    end

    it { should have_selector('title', text: 'All users') }
    it { should have_selector('h1',    text: 'All users') }

    describe "delete links" do
      it "should not be visible to non-admin users" do
        page.should_not have_link('delete')
      end

      describe "as an admin user" do                
        let(:admin) { FactoryGirl.create(:admin) }
        before {
          signin(admin)
          visit users_path
        }
        it { should have_link('delete', href: user_path(User.first)) }
        it "should be able to delete another user" do
          expect { click_link('delete') }.to change(User, :count).by(-1)
        end
        it "should show success message on deletion" do
          click_link('delete')
          page.should have_success_message("User: #{user.name} deleted")
        end
        it { should_not have_link('delete', href: user_path(admin)) }
        describe "deleting himself" do
          before { delete user_path(admin) }
          specify { response.should redirect_to(users_path) }
          describe "should fail" do
            it { should have_link(admin.name) }
          end
        end
      end
    end

    describe "pagination" do
      before(:all) do
        30.times { FactoryGirl.create(:user) }
      end

      after(:all) do
        User.destroy_all
      end

      it { should have_selector('div.pagination') }

      it "should list each user" do
        User.paginate(page: 1).each do |user|
          page.should have_selector('li', text: user.name)
        end
      end
    end
  end

  describe "following/followers" do
    let(:user) { FactoryGirl.create(:user) }
    let(:earlier_follow) { FactoryGirl.create(:user) }
    let(:later_follow) { FactoryGirl.create(:user) }
    before { 
      user.follow!(earlier_follow)
      user.follow!(later_follow)
    }

    describe "followed users" do
      before do
        signin user
        visit following_user_path(user)
      end

      it { should have_selector('title', text: full_title('Following')) }
      it { should have_selector('h3', text: 'Following') }
      it "should show all followed users in reverse creation order" do
        user.followed_users.should == [later_follow, earlier_follow]
      end
    end

    describe "followers" do
      let(:earlier_follower) { FactoryGirl.create(:user) }
      let(:later_follower) { FactoryGirl.create(:user) }
      before do
        earlier_follower.follow!(user)
        later_follower.follow!(user)
        signin user
        visit followers_user_path(user)
      end

      it { should have_selector('title', text: full_title('Followers')) }
      it { should have_selector('h3', text: 'Followers') }
      it "should show all followers users in reverse creation order" do
        user.followers.should == [later_follower, earlier_follower]
      end
    end
  end
end