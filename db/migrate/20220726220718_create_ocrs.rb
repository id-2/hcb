# frozen_string_literal: true

class CreateOcrs < ActiveRecord::Migration[6.1]
  def change
    create_table :ocrs do |t|
      t.text :text
      t.references :document, polymorphic: true

      t.timestamps
    end
  end

end
