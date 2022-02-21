# frozen_string_literal: true

class AddStiTypeToPartner < ActiveRecord::Migration[6.0]
  def change
    add_column :partners, :type, :string
  end

end
