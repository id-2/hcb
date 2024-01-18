# frozen_string_literal: true

class TagsController < ApplicationController
  include SetEvent

  before_action :set_event

  def create
    authorize @event, policy_class: TagPolicy

    tag = @event.tags.find_or_create_by(label: params[:label].strip)

    hcb_code_ids = params[:hcb_code_id] || params[:hcb_code_ids]&.split(",") || []

    HcbCode.where(id: hcb_code_id).find_each do |hcb_code|
      authorize hcb_code, :toggle_tag?

      suppress(ActiveRecord::RecordNotUnique) do
        hcb_code.tags << tag
      end
    end

    redirect_back fallback_location: @event
  end

  def destroy
    tag = Tag.find(params[:id])

    authorize tag

    tag.destroy!

    redirect_back fallback_location: @event
  end

end
