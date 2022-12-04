# frozen_string_literal: true

class CanonicalTransactionComponent < ViewComponent::Base
  include ApplicationHelper
  include UsersHelper

  with_collection_parameter :ct
  def initialize(ct:, event:, organizer_signed_in:, admin_signed_in:, current_user:)
    @ct = ct
    @event = event
    @organizer_signed_in = organizer_signed_in
    @admin_signed_in = admin_signed_in
    @current_user = current_user
  end

  attr_reader :current_user

  def organizer_signed_in?
    @organizer_signed_in
  end

  def admin_signed_in?
    @admin_signed_in
  end
end
