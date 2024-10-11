class CreateNewTransactions < ActiveRecord::Migration[7.2]
  def change
    create_table :new_transactions do |t|
      t.references :event
      t.references :transaction_source, polymorphic: true
      t.datetime :datetime
      t.string :memo
      t.integer :amount_cents
      t.timestamps
    end

    CanonicalTransaction.joins(:canonical_event_mapping).where(canonical_event_mapping: {event_id: 183}).order(date: :desc).first(10).each do |ct|
      NewTransaction.create!(
        amount_cents: ct.amount_cents,
        datetime: ct.created_at,
        memo: ct.smart_memo,
        transaction_source: ct.transaction_source,
        event_id: 183
      )
    end
  end
end
