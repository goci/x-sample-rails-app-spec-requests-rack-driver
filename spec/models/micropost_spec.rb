# == Schema Information
#
# Table name: microposts
#
#  id         :integer          not null, primary key
#  content    :string(255)
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Micropost do
  let(:user) { FactoryGirl.create(:user) }
  before { @micropost = user.microposts.build(content: "Lorem ipsum") }
  subject { @micropost }

  it { should respond_to(:content) }
  it { should respond_to(:user_id) }
  it { should respond_to(:user) }
  its(:user) { should == user   }
  it { should be_valid }   
  
  it "should not allow mass assignment of user" do
    expect { @micropost.update_attributes!(user_id: 1) }.to(
    raise_error(ActiveModel::MassAssignmentSecurity::Error))
  end

  describe "without user" do
    before { @micropost.user_id = nil }
    it { should_not be_valid }
  end
  
  describe "with empty content" do
    before { @micropost.content = '' }
    it { should_not be_valid }
  end
  
  describe "content longer than 140 chars" do
    before { @micropost.content = "a" * 141 }
    it { should_not be_valid }
  end
end
