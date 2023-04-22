namespace :dev do

    task :fake => :environment do
      User.delete_all
      Post.delete_all
      
      users = []
      10.times do
        users << User.create!( :email => Faker::Internet.email, :password => "12345678")
      end
  
      50.times do |i|
        post = Post.create!( :content => Faker::Lorem.paragraph, :user_id => users.sample.id )  
      end
    end
  
end

