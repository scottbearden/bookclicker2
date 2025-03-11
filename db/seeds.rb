require 'faker'

Reservation.destroy_all # Reservations depend on Books and Lists
OneDayInventory.destroy_all
Inventory.destroy_all # Inventories depend on Lists
Book.destroy_all # Books depend on PenNames
Campaign.destroy_all # Campaigns depend on Lists
List.destroy_all # Lists depend on Users and PenNames
PenName.destroy_all # PenNames depend on Users
User.destroy_all # Users are the top-level dependency
Genre.destroy_all

# Create Genres
Genre.create([{ genre: 'Comedy' }, { genre: 'Drama' }, { genre: 'Horror' }, { genre: 'Self Help' },
             { genre: 'Action/Adventure' }, { genre: 'Romance' }, { genre: 'Satire' }, { genre: 'Tragedy' },
             { genre: 'Fantasy' }, { genre: 'Science Fiction' }])

# Create Users
seller_emails = (1..17).map { |i| "seller#{i}@sell.com" }
buyer_emails = (1..3).map { |i| "buyer#{i}@buy.com" }

seller_emails.each do |email|
  User.create!(email: email, role: 'full_member', password: 'seller', first_name: Faker::Name.first_name, last_name: Faker::Name.last_name)
end

buyer_emails.each do |email|
  User.create!(email: email, role: 'full_member', password: 'buyerr', first_name: Faker::Name.first_name, last_name: Faker::Name.last_name)
end

User.all.update_all(email_verified_at: Time.now)


sellers = User.where(email: seller_emails)
buyers = User.where(email: buyer_emails)

# Create Pen Names and Books
sellers.each do |seller|
  author_name = Faker::Book.author
  pen_name = seller.pen_names.create!(author_name: author_name)
  pen_name.update_column(:user_id, seller.id)

  rand(1..3).times do
    title = Faker::Book.title
    book = Book.new(title: title, user_id: seller.id, pen_name: pen_name)
    book.save!
  end
end

# Create Lists and Reservations
sellers.each do |seller|
  seller.pen_names.each do |pen_name|
    rand(1..3).times do
      UsersPenName.find_or_create_by(user_id: seller.id, pen_name_id: pen_name.id)

      list_params = {
        user_id: seller.id,
        pen_name: pen_name,
        platform: PLATFORMS.sample,
        platform_id: rand(100000000000000000..200000000000000000),
        name: ["Promotions", "Sales", "Big list", "My #{Genre.all.sample.genre} list", "Primary", "New Mailing List", "#{PLATFORMS.sample} list", "Special Promos", "Latest promos", "#{Genre.all.sample.genre} Sales"].sample,
        active_member_count: rand(1000..5000),
        open_rate: rand(0.1..0.5),
        click_rate: rand(0.01..0.1),
        feature_price: rand(5..95),
        solo_price: rand(5..95),
        mention_price: rand(5..95),
        status: 'active'
      }

      list = List.create!(list_params)

      # Create Inventories for the list
      ["solo", "feature", "mention"].each do |inv_type|
        ActiveRecord::Base.connection.execute(
          "INSERT INTO inventories (list_id, inv_type, sunday, monday, tuesday, wednesday, thursday, friday, saturday, created_at, updated_at) 
           VALUES (#{list.id}, '#{inv_type}', #{rand(10..50)}, #{rand(10..50)}, #{rand(10..50)}, #{rand(10..50)}, #{rand(10..50)}, #{rand(10..50)}, #{rand(10..50)}, NOW(), NOW())"
        )
      end

      pen_name.books.each do |book|
        num_reservations_to_create = 5 # Create 5 reservations per book

        num_reservations_to_create.times do
          puts "Checking book: #{book.id}, List: #{list.id}"

          inv_type = list.inventories.pluck(:inv_type).sample
          puts "inv_type: #{inv_type.inspect}"

          if inv_type.present?
            price = list.send("#{inv_type}_price")
            puts "price: #{price.inspect}"

            if price.present?
              puts "Price condition met!"
              reservation_params = {
                list_id: list.id,
                book_id: book.id,
                inv_type: inv_type,
                date: Date.today + rand(1..60),
                price: price,
                recorded_list_name: list.name,
                premium: rand(0..10),
                seller_accepted_at: [Time.now - rand(0..30).days, nil].sample
              }

              # Randomly choose payment or swap (but not both)
              if rand(2) == 0
                reservation_params[:payment_offer] = true
                reservation_params[:swap_offer] = false
              else
                reservation_params[:payment_offer] = false
                reservation_params[:swap_offer] = true

                # Handle swap offer details
                if reservation_params[:swap_offer]
                  swap_list = List.where(user_id: seller.id).sample
                  if swap_list
                    reservation_params[:swap_offer_list_id] = swap_list.id
                    # Set at least one swap_offer_inv_type (e.g., solo)
                    reservation_params[:swap_offer_solo] = true
                    reservation_params[:swap_offer_feature] = false
                    reservation_params[:swap_offer_mention] = false
                  else
                    puts "No suitable swap list found for seller #{seller.id}."
                    reservation_params[:swap_offer] = false # Don't create the swap offer
                    reservation_params[:payment_offer] = true # Create paid offer instead
                  end
                end
              end

              if !reservation_params[:payment_offer] && !reservation_params[:swap_offer]
                # If both are false, set one to true. You can choose which one.
                reservation_params[:payment_offer] = true  # Or reservation_params[:swap_offer] = true
            end

              reservation = Reservation.create!(reservation_params)
              puts "Reservation created: #{reservation.inspect}"
            else
              puts "Price not found for inv_type: #{inv_type}"
            end
          else
            puts "inv_type not found for list: #{list.id}"
          end
        end
      end
    end
  end
end

# Create Campaigns (for lists)
List.all.each do |list|
  rand(1..3).times do
    campaign_params = {
      list_id: list.id,
      platform_id: list.platform_id,
      sent_on: Date.today - rand(0..30),
      sent_at: Time.now - rand(0..30).days,
      emails_sent: rand(100..500),
      open_rate: rand(0.2..0.6),
      click_rate: rand(0.02..0.1),
      subject: Faker::Lorem.sentence,
      name: Faker::Company.name
    }
    Campaign.find_or_create_by(list_id: list.id, platform_id: list.platform_id) do |campaign|
      campaign.attributes = campaign_params
    end
  end
end

puts "Seeds planted successfully!"