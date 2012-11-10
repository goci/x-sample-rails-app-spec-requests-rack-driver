namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    admin
    users
    microposts
    relationships
  end
end

private

def admin
  admin = User.create!(name: "Sahil Muthoo",
                       email: "sahil.muthoo@gmail.com",
                       password: "foobar",
                       password_confirmation: "foobar")
  admin.toggle!(:admin)
end

def users
  User.transaction do
    99.times do |n|
      name  = Faker::Name.name
      email = "foobar-#{n+1}@example.org"
      password  = "password"
      User.create!(name: name,
                   email: email,
                   password: password,
                   password_confirmation: password)
    end
  end
end

def microposts
  Micropost.transaction do
    User.all(limit: 5).each do |user|
      50.times do
        content = Faker::Lorem.sentence((5..10).to_a.sample)
        user.microposts.create!(content: content)
      end
    end  
  end
end

def relationships
  User.transaction do
    users = User.all
    user  = users.first
    followed_users = users[2..50]
    followers      = users[3..40]
    followed_users.each { |followed| user.follow!(followed) }
    followers.each      { |follower| follower.follow!(user) }
  end
end
