# frozen_string_literal: true

class AddProductToDonations < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_reference :donations, :product, null: true, index: { algorithm: :concurrently }
  end

end
