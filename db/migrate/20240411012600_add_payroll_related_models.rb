class AddPayrollRelatedModels < ActiveRecord::Migration[7.0]
  def change
    create_table :gusto_contractors do |t|
      t.string :gusto_id, null: false
      t.string :gusto_version, null: false
      t.jsonb :gusto_object
      t.belongs_to :user, null: false, foreign_key: true
    end
    
    create_table :gusto_departments do |t|
      t.string :gusto_id, null: false
      t.string :gusto_version, null: false
      t.jsonb :gusto_object
      t.belongs_to :event, null: false, foreign_key: true
    end
    
        
    create_table :contractor_positions do |t|
      t.belongs_to :gusto_contractor, null: false, foreign_key: true
      t.belongs_to :event, null: false, foreign_key: true
    end
    
    create_table :gusto_contractor_payments do |t|
      t.string :gusto_id, null: false
      t.string :gusto_version, null: false
      t.jsonb :gusto_object
      t.belongs_to :contractor_position, null: false, foreign_key: true
      t.integer :amount_cents, null: false
    end

    create_table :gusto_access_tokens do |t|
      t.string :access_token, null: false
      t.string :refresh_token, null: false
      t.datetime :expires_at, null: false
    end

  end
end
