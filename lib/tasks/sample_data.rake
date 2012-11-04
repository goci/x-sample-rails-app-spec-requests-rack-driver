namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    admin = User.create!(name: "Sahil Muthoo",email: "sahil.muthoo@gmail.com",password: "foobar",password_confirmation: "foobar")
    admin.toggle!(:admin)
    User.transaction do
      99.times do |n|
        name  = Faker::Name.name
        email = "foobar-#{n+1}@example.org"
        password  = "password"
        User.create!(name: name,email: email,password: password,password_confirmation: password)
      end
      User.all(limit: 6).each do |user|
        50.times do
          content = Faker::Lorem.sentence((5..10).to_a.sample)
          user.microposts.create!(content: content)
        end
      end
    end
  end
end