# frozen_string_literal: true

class AnnouncementsController < ApplicationController
  before_action :set_announcement

  def index
    authorize @announcement

    @all_announcements = Announcement.where(event: @event).order(created_at: :desc, draft: :desc, published_at: :desc)
    @announcements = Kaminari.paginate_array(@all_announcements).page(params[:page]).per(10)
  end

  def new
    authorize @announcement
  end

  def create
    @announcement = @event.announcements.build(params.require(:announcement).permit(:title, :content).merge(user: current_user, draft: true))

    authorize @announcement

    @announcement.save!

    unless @announcement.draft
      @announcement.publish
    end

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

  def edit
    authorize @announcement

    render "announcements/show", locals: { editing: true }
  end

  def update
    authorize @announcement

    @announcement.update!(params.require(:announcement).permit(:title, :content, :draft))

    flash[:success] = "Updated announcement"

    if params[:announcement][:autosave] != "true"
      redirect_to event_announcement_path(@event, @announcement)
    end
  end

  def destroy
    authorize @announcement

    @announcement.destroy!

    flash[:success] = "Deleted announcement"

    redirect_to event_announcements_path(@event)
  end

  def publish
    authorize @announcement

    @announcement.publish

    flash[:success] = "Published announcement"

    redirect_to event_announcement_path(@event, @announcement)
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
