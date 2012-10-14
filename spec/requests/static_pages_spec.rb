require 'spec_helper'


describe "StaticPages" do
  let (:title_prefix) { 'Ruby on Rails Tutorial Sample App | ' }
  describe "Home Page" do
    before(:each) do
      visit '/static_pages/home'
    end
    it "should have the content 'Sample App'" do
      page.should have_selector('h1', text: "Sample App")
    end
    
    it "should have the title 'Home'" do
      page.should have_selector('title', 
                      text: "#{title_prefix}Home")
    end
  end
  
  describe "Help Page" do
    before(:each) do
      visit '/static_pages/help'
    end
    
    it "should have the content 'Help'" do
      page.should have_selector('h1', text: 'Help')
    end
    
    it "should have the title 'Help'" do
      page.should have_selector('title', 
                      text: "#{title_prefix}Help")
    end
  end
  
  describe "About Page" do
    before(:each) do
      visit '/static_pages/about'
    end
    
    it "should have the content 'About Us'" do
      visit '/static_pages/about'
      page.should have_selector('h1', text: 'About Us')
    end
    
    it "should have the title 'About Us'" do
      page.should have_selector('title', 
                      text: "#{title_prefix}About Us")
    end
  end
  
  describe "Contant Page" do
    before(:each) do
      visit '/static_pages/contact'
    end
    
    it "should have the content 'Contact'" do
      page.should have_selector('h1', text: 'Contact')
    end
    
    it "should have the title 'About Us'" do
      page.should have_selector('title', 
                      text: 'Ruby on Rails Tutorial Sample App | Contact')
    end
  end
end
