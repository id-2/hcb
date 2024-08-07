class CreateEventApplications < ActiveRecord::Migration[7.1]
  def change
    create_table :event_applications do |t|
      t.string :user_first_name, null: false
      t.string :user_last_name, null: false
      t.string :user_email, null: false
      t.string :user_phone, null: false
      t.string :user_birthday, null: false
      t.string :event_name, null: false
      t.string :event_website
      t.text :event_description
      t.string :event_address_postal_code, null: false
      t.string :event_address_country_code_iso3166, null: false
      t.boolean :existing_user, null: false
      t.string :referrer
      t.boolean :transparent, null: false
      t.integer :contact_option, null: false
      t.string :slack_username
      t.text :accommodations

      t.timestamps
    end
  end

end
