require 'spec_helper'

describe "Authentication" do

  subject { page }

  describe "signin page" do
    before { visit signin_path }

    it { should have_selector('h1',    text: 'Sign in') }
    it { should have_selector('title', text: 'Sign in') }

    describe "with invalid information" do
      before { click_button "Sign in" }

      it { should have_selector('title', text:'Sign in') }
      it { should have_error_message('Invalid') }
      describe "after visiting another page" do
        before { click_link 'Home' }
        it { should_not have_error_message }
      end
    end

    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        signin(user)
      end

      it { should have_selector('title',    text: user.name) }
      it { should have_link('Users',    href: users_path) }
      it { should have_link('Profile',      href: user_path(user)) }
      it { should have_link('Settings',     href: edit_user_path(user)) }      
      it { should have_link('Sign out',     href: signout_path) }
      it { should_not have_link('Sign In',  href: signin_path) }
    end
  end

  describe "authorization" do

    describe "as the wrong user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:evil_user) { FactoryGirl.create(:user, name: "Dr. Evil", email: "foo@bar") }

      describe "trying to edit someone else's profile" do
        before {
          signin(evil_user)
          visit edit_user_path(user) 
        }
        it { should_not have_selector('title', text: full_title('Edit user')) }
      end
      describe "trying the update someone else's profile" do
        before {
          signin(evil_user)
          put user_path(user)
        }
        specify { response.should redirect_to(root_path) }
      end
    end

    describe "for non-admin user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:non_admin) { FactoryGirl.create(:user) }
      before { signin(non_admin) }
      describe "in the Users controller" do
        describe "triggering the delete action" do
          before { delete user_path(user) }
          specify { response.should redirect_to(root_path) }
        end
      end
    end

    describe "for non signed-in users" do
      let(:user) { FactoryGirl.create(:user) }

      describe "in the Microposts controller" do
        describe "trying to create a micropost" do
          before { post microposts_path }
          specify { response.should redirect_to(signin_path) }
        end
        describe "trying to delete a micropost" do
          before { delete micropost_path(FactoryGirl.create(:micropost)) }
          specify { response.should redirect_to(signin_path) }
        end
      end

      describe "in the Relationships controller" do
        describe "submitting to the create action" do
          before { post relationships_path }
          specify { response.should redirect_to(signin_path) }
        end

        describe "submitting to the destroy action" do
          before { delete relationship_path(1) }
          specify { response.should redirect_to(signin_path) }          
        end
      end

      describe "visiting the following page" do
        before { visit following_user_path(user) }
        it { should have_selector('title', text: 'Sign in') }
      end

      describe "visiting the followers page" do
        before { visit followers_user_path(user) }
        it { should have_selector('title', text: 'Sign in') }
      end

      describe "signed-in specific links don't show up " do
        it { should_not have_link('Profile') }
        it { should_not have_link('Settings') }      
        it { should_not have_link('Sign out') }

      end
      describe "when attempting to visit a protected page" do
        before {
          visit edit_user_path(user)
          signin(user)
        }
        describe "after signing in" do
          it { should have_selector('title', text: full_title('Edit user')) }

          describe "when signing in again" do
            before {
              delete signout_path
              signin(user)
            }
            describe "should render the default (profile) page" do
              it { should have_selector('title', text: user.name) }
            end
          end
        end
      end
      describe "in the Users controller" do
        describe "visiting the edit path" do
          before { visit edit_user_path(user) }
          it { should have_selector('title', text: 'Sign in') }
          it { should have_notice_message('Please sign in') }
        end
        describe "triggering the update action" do
          before { put user_path(user) }
          specify { response.should redirect_to(signin_path) }
        end
        describe "visiting the user index page" do
          before { visit users_path }
          it { should have_selector('title', text: 'Sign in') }
          it { should have_notice_message('Please sign in') }
        end 
      end
    end
    describe "for signed-in users" do
      let(:user) { FactoryGirl.create(:user) }
      before { signin(user) }
      describe "in the Users controller" do
        describe "trying to signup again" do
          before { get signup_path }
          specify { response.should redirect_to(root_path) }
        end
        describe "trying to create a new user" do
          before { post users_path }
          specify { response.should redirect_to(root_path) }
        end
      end
    end
  end
end
