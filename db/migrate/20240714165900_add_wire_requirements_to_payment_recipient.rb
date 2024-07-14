class AddWireRequirementsToPaymentRecipient < ActiveRecord::Migration[7.1]
  def change
    add_column :payment_recipients, :bic_number_ciphertext, :text
    add_column :payment_recipients, :address_line1_ciphertext, :text
    add_column :payment_recipients, :address_line2_ciphertext, :text
    add_column :payment_recipients, :address_city_ciphertext, :text
    add_column :payment_recipients, :address_postal_code_ciphertext, :text
    add_column :payment_recipients, :address_country_code_ciphertext, :text
    add_column :payment_recipients, :legal_id_ciphertext, :text
    add_column :payment_recipients, :legal_type_ciphertext, :text
    add_column :payment_recipients, :local_account_number_ciphertext, :text
    add_column :payment_recipients, :local_bank_code_ciphertext, :text
    add_column :payment_recipients, :phone_ciphertext, :text
    add_column :payment_recipients, :email, :string
  end
end
