# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.where("email regexp 'seller|buyer'").destroy_all

seller1 = User.create!(email: 'seller1@sell.com', role: 'full_member', password: 'seller', first_name: 'Ralph', last_name: 'Christmas')
seller2 = User.create!(email: 'seller2@sell.com', role: 'full_member', password: 'seller', first_name: 'Dave', last_name: 'Inskeep')
seller3 = User.create!(email: 'seller3@sell.com', role: 'full_member', password: 'seller', first_name: 'Jared', last_name: 'Scheib')
seller4 = User.create!(email: 'seller4@sell.com', role: 'full_member', password: 'seller', first_name: 'Matt', last_name: 'Smith')
seller5 = User.create!(email: 'seller5@sell.com', role: 'full_member', password: 'seller', first_name: 'Suzie', last_name: 'Adams')
seller6 = User.create!(email: 'seller6@sell.com', role: 'full_member', password: 'seller', first_name: 'Mark', last_name: 'Wahlberg')
seller7 = User.create!(email: 'seller7@sell.com', role: 'full_member', password: 'seller', last_name: 'Aristotle')
seller8 = User.create!(email: 'seller8@sell.com', role: 'full_member', password: 'seller')
seller9 = User.create!(email: 'seller9@sell.com', role: 'full_member', password: 'seller', first_name: 'Dane', last_name: 'Cook')
seller10 = User.create!(email: 'seller10@sell.com', role: 'full_member', password: 'seller', first_name: 'Louis', last_name: 'C.K.')
seller11 = User.create!(email: 'seller11@sell.com', role: 'full_member', password: 'seller', first_name: 'Ellen', last_name: 'Degeneres')
seller12 = User.create!(email: 'seller12@sell.com', role: 'full_member', password: 'seller', first_name: 'Tom', last_name: 'Hanks')
seller13 = User.create!(email: 'seller13@sell.com', role: 'full_member', password: 'seller', first_name: 'Courtney', last_name: 'Court')
seller14 = User.create!(email: 'seller14@sell.com', role: 'full_member', password: 'seller', first_name: 'Charles', last_name: 'Dickens')
seller15 = User.create!(email: 'seller15@sell.com', role: 'full_member', password: 'seller')
seller16 = User.create!(email: 'seller16@sell.com', role: 'full_member', password: 'seller')
seller17 = User.create!(email: 'seller17@sell.com', role: 'full_member', password: 'seller', first_name: 'Bill', last_name: 'Shakespeare')
buyer1 = User.create!(email: 'buyer1@buy.com', role: 'full_member', password: 'buyerr', first_name: 'Carlos', last_name: 'Menjivar')
buyer2 = User.create!(email: 'buyer2@buy.com', role: 'full_member', password: 'buyerr', first_name: 'Lawrence', last_name: 'Krauss')
buyer3 = User.create!(email: 'buyer3@buy.com', role: 'full_member', password: 'buyerr', first_name: 'Fareed', last_name: 'Zakariah')

Genre.create(genre: 'Comedy')
Genre.create(genre: 'Drama')
Genre.create(genre: 'Horror')
Genre.create(genre: 'Self Help')
Genre.create(genre: 'Action/Adventure')
Genre.create(genre: 'Romance')
Genre.create(genre: 'Satire')
Genre.create(genre: 'Tragedy')
Genre.create(genre: 'Fantasy')
Genre.create(genre: 'Science Fiction')

[ seller1, seller2, seller3, seller4, seller5, 
  seller6, seller7, seller8, seller9, seller10,
  seller11, seller12, seller13, seller14, seller15, seller16, seller17].each do |seller| 
  (rand(3) + 1).times do
    genre = Genre.all.sample
    platform = PLATFORMS.sample
    list_name = ["Promotions", "Sales", "Big list", "My #{genre.genre} list", "Primary", "New Mailing List", "#{platform} list", "Special Promos", "Latest promos", "#{genre.genre} Sales"].sample
    list_params = {
      platform: platform, 
      name: list_name, 
      active_member_count: rand(1000),
      open_rate: rand(),
      click_rate: rand(),
      feature_price: [rand(95) + 5, nil].sample,
      solo_price: [rand(95) + 5, nil].sample,
      mention_price: [rand(95) + 5, nil].sample
    }
    created_list = seller.lists.create!(list_params)
    inv_type = if created_list.feature_price?; "feature"; elsif created_list.solo_price?; "solo" 
    elsif created_list.mention_price?; "mention"; else; nil; end
    if inv_type
      created_list.inventories.create!(inv_type: inv_type, monday: rand(2), tuesday: rand(2), wednesday: rand(2), thursday: rand(2), friday: rand(2))
    end
  end
end

User.all.update_all(email_verified_at: Time.now)

