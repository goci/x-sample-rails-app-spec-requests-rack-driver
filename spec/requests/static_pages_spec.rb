require 'spec_helper'

describe "Static pages" do
  subject { page }
  shared_examples_for "all static pages" do
    it { should have_selector('h1', text: heading) }
    it { should have_selector('title', text: title) }
  end

  describe "Home Page" do
    before { visit root_path }
    let(:heading) { 'Sample App' }
    let(:title)   { full_title('') }
    let(:user) { FactoryGirl.create(:user) }
    it_should_behave_like "all static pages"
    describe "when signed in" do
      describe "sidebar" do
        before {
          FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")
          signin user
          visit root_path
        }
        it "should render micropost count" do
          page.should have_content('1 micropost')
          FactoryGirl.create(:micropost, user: user, content: "Foo")
          visit root_path
          page.should have_content('2 microposts')
        end
      end
      
      describe "pagination" do
        before(:all) do
          50.times { FactoryGirl.create(:micropost, user: user) }
        end

        after(:all) do
          User.destroy_all
        end
        
        before {
          signin user
          visit root_path
        }

        it { should have_selector('div.pagination') }

        it "should list each micropost" do
          Micropost.paginate(page: 1).each do |mp|
            page.should have_selector('li', text: mp.content)
          end
        end
      end
      
      
      
      describe "feed" do
        before {
          FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")
          FactoryGirl.create(:micropost, user: user, content: "Dolor sit amet")
          signin user
          visit root_path
        }
        it "should render the user's feed" do
          user.feed.each do |item|
            page.should have_selector("li##{item.id}", text: item.content)
          end
        end
        it "should wrap long microposts" do
          long_mp = FactoryGirl.create(:micropost, user: user, content: 'a' * 140)
          visit root_path
          zero_width_space = "&#8203;"
          page.should have_selector("li##{long_mp.id}", contains: zero_width_space)
        end
      end
    end    
  end
  
  describe "Help Page" do
    before { visit help_path }
    let(:heading) { 'Help' }
    let(:title)   { full_title('Help') }
    it_should_behave_like "all static pages"
  end

  describe "About Page" do
    before { visit about_path }
    let(:heading) { 'About' }
    let(:title)   { full_title('About') }
    it_should_behave_like "all static pages"
  end

  describe "Contact Page" do
    before { visit contact_path }
    let(:heading) { 'Contact' }
    let(:title)   { full_title('Contact') }
    it_should_behave_like "all static pages"
  end  
end
