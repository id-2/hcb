# frozen_string_literal: true

class AddExtraFieldsToPartneredSignup < ActiveRecord::Migration[6.0]
  def change
    add_column :partnered_signups, :organization_url, :text
    add_column :partnered_signups, :organization_description, :text
  end

end
