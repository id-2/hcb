module YellowPagesService

  class MissingMerchants
    def calculate
      RawStripeTransaction.select(
        "raw_stripe_transactions.stripe_transaction->'merchant_data'->>'network_id' AS merchant_network_id",
        "CASE
             WHEN raw_stripe_transactions.stripe_transaction->'merchant_data'->>'name' SIMILAR TO '(SQ|GOOGLE|TST|RAZ|INF|PayUp|IN|INT|\\*)%'
               THEN TRIM(UPPER(raw_stripe_transactions.stripe_transaction->'merchant_data'->>'name'))
             ELSE TRIM(UPPER(SPLIT_PART(raw_stripe_transactions.stripe_transaction->'merchant_data'->>'name', '*', 1)))
           END AS merchant_name",
        "SUM(raw_stripe_transactions.amount_cents) * -1 AS amount_spent"
      )
                          .joins("LEFT JOIN canonical_transactions ct ON raw_stripe_transactions.id = ct.transaction_source_id")
                          .where("EXTRACT(YEAR FROM date_posted) = ?", 2024)
                          .group(
                            "raw_stripe_transactions.stripe_transaction->'merchant_data'->>'network_id'",
                            "CASE
               WHEN raw_stripe_transactions.stripe_transaction->'merchant_data'->>'name' SIMILAR TO '(SQ|GOOGLE|TST|RAZ|INF|PayUp|IN|INT|\\*)%'
                 THEN TRIM(UPPER(raw_stripe_transactions.stripe_transaction->'merchant_data'->>'name'))
               ELSE TRIM(UPPER(SPLIT_PART(raw_stripe_transactions.stripe_transaction->'merchant_data'->>'name', '*', 1)))
             END"
                          )
                          .having("count(*) > 10")
                          .order(Arel.sql("SUM(raw_stripe_transactions.amount_cents) * -1 DESC"))
                          .limit(100)
                          .each_with_object({}) do |item, hash|
                            name = YellowPages::Merchant.lookup(network_id: item.merchant_network_id).name
                            next if name
                            hash[item.merchant_network_id] ||= { amount: 0, names: [] }
                            hash[item.merchant_network_id][:amount] += item[:amount_spent]
                            hash[item.merchant_network_id][:names].append item.merchant_name
                          end.sort_by { |k, v| v[:amount] }.reverse!
    end

  end

end
