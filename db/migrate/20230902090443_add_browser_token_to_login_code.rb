class AddBrowserTokenToLoginCode < ActiveRecord::Migration[7.0]
  def change
    add_column :login_codes, :browser_token_bidx, :string
    add_column :login_codes, :browser_token_ciphertext, :string
  end

end
