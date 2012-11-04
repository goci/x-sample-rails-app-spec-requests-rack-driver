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
      before do
        FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")
        FactoryGirl.create(:micropost, user: user, content: "Dolor sit amet")
        signin user
        visit root_path
      end
      it "should render the user's feed" do
        user.feed.each do |item|
          page.should have_selector("li##{item.id}", text: item.content)
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
