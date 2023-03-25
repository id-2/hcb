# frozen_string_literal: true

class Announcement < Bulletin
  def title
    super.presence || "SVB Fiasco: Barely Avoided"
  end

end
