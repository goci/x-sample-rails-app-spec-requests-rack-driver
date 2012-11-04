require 'spec_helper'

describe "Micropost pages" do

  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  before { signin(user) }

  describe "micropost creation" do
    before { visit root_path }

    describe "with invalid information" do

      it "should not create a micropost" do
        expect { click_button "Post" }.not_to change(Micropost, :count)
      end

      describe "error messages" do
        before { click_button "Post" }
        it { should have_error_message } 
      end
    end

    describe "with valid information" do

      before { fill_in 'micropost_content', with: "Lorem ipsum" }
      it "should create a micropost" do
        expect { click_button "Post" }.to change(Micropost, :count).by(1)
      end
    end
  end

  describe "micropost destruction" do
    let!(:mp) { FactoryGirl.create(:micropost, user: user) }
    describe "as correct user" do
      before { visit root_path }

      it "should delete a micropost" do
        expect { click_link "delete" }.to change(Micropost, :count).by(-1)
      end
    end
    describe "as invalid user" do
      let(:evil_user) { FactoryGirl.create(:user) }
      before {
        signin evil_user
        visit root_path
      }
      it { should_not have_link('delete') }
      describe "in the Microposts controller" do
        describe "attempting to delete someone else's micropost" do
          it "should fail" do
            expect { delete micropost_path(mp) }.not_to change(Micropost, :count)
          end
          it "should redirect to the root path" do
            delete micropost_path(mp)
            response.should redirect_to(root_path)
          end
        end
      end
    end
  end
end