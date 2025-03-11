class AddPenNameIdToBooks < ActiveRecord::Migration[5.0]
  def change
    
    execute("create table aaa_books_#{Time.now.to_s.delete("- +:")} as select * from books")
    
    add_column :books, :pen_name_id, :integer, after: 'user_id'
    
    User.full_member.each_with_index do |user, idx|
      pen_name = user.pen_names.create!({
        author_name: user.full_name.presence || user.email.match(/^(.+)\@/)[1],
        verified: 0
      })
      user.books.update_all(pen_name_id: pen_name.id)
    end
    
  end
end
