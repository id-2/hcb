# frozen_string_literal: true

class CanonicalTransactionComponent < ViewComponent::Base
  include ApplicationHelper
  include SessionsHelper
  include UsersHelper

  with_collection_parameter :ct
  def initialize(ct:, event:, current_user:)
    super
    @ct = ct
    @event = event
    @current_user = current_user
  end

  # current_user is needed here because current_user in SessionsHelper
  # calls current_session which errors here due to cookies not being
  # available in the component
  # https://github.com/hackclub/bank/blob/cdb44c5867eb16cc177cba24b84e7eaa6d266033/app/helpers/sessions_helper.rb#L77
  #
  # Even without this issue, components are meant to take in all the data they need to render the view as arguments,
  # so if we end up moving forward with view_component, we should probably move away from including the helpers
  # in this class anyway since they add implicit dependencies.
  attr_reader :current_user

end
