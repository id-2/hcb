# frozen_string_literal: true

module Api
  class Directory < Grape::API
    include Grape::Kaminari

    desc "Endpoints for HCB directory" do
      hidden true # Don't list endpoints in OpenAPI spec/docs
    end
    namespace "directory" do
      params do
        use :pagination, per_page: 50, max_per_page: 100
      end
      get :organizations do
        orgs = Event.indexable.includes(:event_tags) # Transparent organizations
                    .or(
                      # Tagged as okay to list in the Climate Directory
                      Event.includes(:event_tags).where({ event_tags: { name: EventTag::Tags::CLIMATE, purpose: :directory } }),
                    )
        orgs = Event.where(id: orgs.select(:id))
                    .includes(:event_tags)
                    .with_attached_logo.with_attached_background_image

        @organizations = paginate(orgs.reorder(name: :asc))

        present @organizations, with: Api::Entities::DirectoryOrganization
      end
      get :hq_organizations do
        present Event.transparent.hack_club_hq, with: Api::Entities::DirectoryOrganization
      end
      params do
        use :pagination, per_page: 50, max_per_page: 100
      end
      get :hq_transactions do
        @transactions ||=
        begin
          transactions = Rails.cache.fetch("hq_transactions", expires_in: 20.minutes) do
            transactions_array = []
            transactions_array += PendingTransactionEngine::PendingTransaction::All.new(event_id: 183, hack_club_hq: true).run
            transactions_array += TransactionGroupingEngine::Transaction::All.new(event_id: 183, hack_club_hq: true).run
          end
          combined = paginate(Kaminari.paginate_array(transactions))
          combined.map(&:local_hcb_code)
        end
        present @transactions, with: Api::Entities::Transaction, **type_expansion(expand: %w[transaction])
      end
    end

  end
end
