class Gravatar
    
  def initialize(user, options)
    @user = user
    @options = options
  end
    
  def url
    gravatar_id = Digest::MD5::hexdigest(@user.email.downcase)
    size = @options[:size]
    "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
  end
end
