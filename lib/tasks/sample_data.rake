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
    end
  end
end