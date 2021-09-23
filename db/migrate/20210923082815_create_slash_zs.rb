# frozen_string_literal: true

class CreateSlashZs < ActiveRecord::Migration[6.0]
  def change
    create_table :slash_zs do |t|
      t.string :zoom_id
      t.string :aasm_state
      t.datetime :started_at
      t.datetime :ended_at
      t.string :host_join_url
      t.string :join_url
      t.string :host_key
      t.references :event, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
