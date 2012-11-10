class FakeGravatar
    
  def initialize(user, options)
    @user = user
    @options = options
  end
    
  def url
    "rails.png"
  end
end
