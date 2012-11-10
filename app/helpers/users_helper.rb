module UsersHelper
  Gravatar = CustomDelegate.new("Gravatar")
  
  def gravatar_for(user, options={ size: 50 })
    image_tag(Gravatar.new(user,options).url, alt: user.name, class: "gravatar")
  end
end