# frozen_string_literal: true

class AnnouncementsController < ApplicationController
  before_action :set_announcement

  def index
    authorize @announcement
  end

  def new
    authorize @announcement
  end

  def create
    @announcement = @event.announcements.build(params.require(:announcement).permit(:title, :content, :draft).merge(user: current_user))

    authorize @announcement

    @announcement.save!

    flash[:success] = "Announcement successfully created!"

  rescue => e
    flash[:error] = "Something went wrong. #{e.message}"
    Rails.error.report(e)
  ensure
    redirect_to event_announcement_path(@event, @announcement)
  end

  def show
    authorize @announcement
  end

  private

  def set_announcement

    if params[:id].present?
      @announcement = Announcement.find(params[:id])
    else
      @announcement = Announcement.new
    end

    if params[:event_id].present?
      @event = Event.find_by(slug: params[:event_id])
      @announcement.event = @event
    end
  end

end
