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
#  remember_token  :string(255)
#  admin           :boolean          default(FALSE)
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
  it { should respond_to(:remember_token) }
  it { should respond_to(:admin?) }
  it { should respond_to(:microposts) }
  it { should respond_to(:feed) }
  it { should respond_to(:relationships) }
  it { should respond_to(:followed_users) }
  it { should respond_to(:followers) }
  it { should respond_to(:following?) }
  it { should respond_to(:follow!) }
  it { should respond_to(:unfollow!) }
  it { should be_valid }
  it { should_not be_admin }

  describe "following" do
    let(:other_user) { FactoryGirl.create(:user) }    
    before do
      @user.save
      @user.follow!(other_user)
    end

    it { should be_following(other_user) }
    its(:followed_users) { should include(other_user) }
    describe "followed user" do
      subject { other_user }
      its(:followers) { should include(@user) }
    end
    describe "and unfollowing" do
      before { @user.unfollow!(other_user) }
      it { should_not be_following(other_user) }
      its(:followed_users) { should_not include(other_user) }
    end
  end

  describe "admin access" do
    before {
      @user.save!
    }
    describe "toggling should enable admin rights" do
      before { @user.toggle!(:admin) }
      it { should be_admin }
    end
    describe "mass assignment" do
      it "should raise error" do
        expect { @user.update_attributes!(admin: true) }.to(
        raise_error(ActiveModel::MassAssignmentSecurity::Error))
      end
    end
  end
  describe "remember token" do
    before { @user.save }
    its(:remember_token) { should_not be_blank }  
  end

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
      @user.email.should == "foo@bar.com"
    end
  end

  describe "relationship associations" do
    let(:other_user) { FactoryGirl.create(:user) }
    before {
      @user.save
      @user.follow!(other_user)
      other_user.follow!(@user)
    }
    describe "destroying the user" do
      let!(:deleted_relationships) { @user.relationships.dup }
      let!(:deleted_reverse_relationships) { @user.reverse_relationships.dup }
      before { @user.destroy }
      it "should destroy the user's relations" do
        deleted_reverse_relationships.should_not be_empty
        deleted_relationships.should_not be_empty
        deleted_reverse_relationships + deleted_relationships.each do |rel|
          Relationship.find_by_id(rel.id).should be_nil
        end
      end
    end
  end

  describe "micropost associations" do
    before { @user.save }
    let!(:older_micropost) { FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago )}
    let!(:newer_micropost) { FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago )}
    describe "should have correct ordering" do
      its(:microposts) { should == [newer_micropost, older_micropost] }
    end

    describe "status" do
      let(:unfollowed_post) do
        FactoryGirl.create(:micropost, user: FactoryGirl.create(:user))
      end
      let(:followed_user) { FactoryGirl.create(:user) }

      before do
        @user.follow!(followed_user)
        3.times { followed_user.microposts.create!(content: "Lorem ipsum") }
      end

      its(:feed) { should include(newer_micropost) }
      its(:feed) { should include(older_micropost) }
      its(:feed) { should_not include(unfollowed_post) }
      its(:feed) do
        followed_user.microposts.each do |micropost|
          should include(micropost)
        end
      end
    end

    describe "destroying the user" do
      let!(:deleted_microposts) { @user.microposts.dup }
      before { @user.destroy }
      it "should destroy the user's microposts" do
        deleted_microposts.should_not be_empty
        deleted_microposts.each do |mp|
          Micropost.find_by_id(mp.id).should be_nil
        end
      end
    end
  end
end