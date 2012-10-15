# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  email           :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  password_digest :string(255)
#

require 'spec_helper'

describe User do
  before do
    @user = User.new name: "Example User",
                     email: "user@example.com",
                     password: "password",
                     password_confirmation: "password"
  end
  subject { @user }
  
  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:authenticate) }
  it { should be_valid }
  
  describe "when name is not present" do
    before { @user.name = " "}
    it { should_not be_valid }
  end
  
  describe "when email is not present" do
    before { @user.email = " "}
    it { should_not be_valid }
  end
  
  describe "when email is invalid" do
    %w(foo @bar.com xyz.com).each do |invalid_email|
      before { @user.email = invalid_email }
      it { should_not be_valid }
    end
  end
  
  describe "when email is valid" do
    %w(foo@bar.com example@foo).each do |valid_email|
      before { @user.email = valid_email }
      it { should be_valid }
    end
  end
  
  describe "when email is duplicate" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.save
    end
    it { should_not be_valid }
  end
  
  describe "when email is duplicate (ignoring case)" do
    before do
      user_with_same_email_different_case = @user.dup
      user_with_same_email_different_case.email.upcase!
      user_with_same_email_different_case.save
    end
    it { should_not be_valid }
  end
  
  describe "when password is not present" do
    before { @user.password = " "}
    it { should_not be_valid }    
  end
  
  describe "when password doesn't match its confirmation" do
    before { @user.password_confirmation = "foobar" }
    it { should_not be_valid }
  end
  
  describe "when password confirmation is nil" do
    before { @user.password_confirmation = nil }
    it { should_not be_valid }
  end
  
  describe "when a password is too short" do
    before { @user.password = "foo"}
    it { should_not be_valid }
  end
  
  describe "return value of authenticate method" do
    before { @user.save }
    let(:found_user) { User.find_by_email(@user.email) }
    
    describe "with valid password" do
      it { should == found_user.authenticate(@user.password) }
    end
    
    describe "with invalid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid_password") }
      specify { user_for_invalid_password.should be_false }
    end
  end
  
  describe "before save" do
    it "should downcase email" do
        @user.email = "FOO@BAR.COM"
        @user.save
        @user.reload.email.should == "foo@bar.com"
    end
  end
end
