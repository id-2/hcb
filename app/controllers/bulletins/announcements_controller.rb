# frozen_string_literal: true

class Bulletins::AnnouncementsController < ApplicationController
  before_action :set_announcement, except: [:new, :create]
  before_action :authorize_announcement

  def new
    @announcement = Announcement.new
  end

  def create
    @announcement = Announcement.new(announcement_params)

    if @announcement.save
      redirect_to @announcement
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    if @announcement.update(announcement_params)
      redirect_to @announcement
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @announcement.destroy

    redirect_to root_path
  end

  private

  def set_announcement
    @announcement = Announcement.find(params[:id])
  end

  def announcement_params
    params.require(:announcement).permit(:title, :content)
  end

  def authorize_announcement
    authorize(@announcement || Announcement.new)
  end

end
