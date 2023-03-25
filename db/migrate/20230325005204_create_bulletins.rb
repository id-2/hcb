# frozen_string_literal: true

class CreateBulletins < ActiveRecord::Migration[7.0]
  def change
    create_table :bulletins do |t|
      t.string :type

      t.string :title

      t.integer :status, default: 0, null: false
      t.datetime :published_at

      t.belongs_to :author

      t.timestamps

      t.index [:type, :status, :published_at, :author_id], name: "idx_bulletins_on_type_and_status_and_published_at_and_author_id"
    end
  end

end
