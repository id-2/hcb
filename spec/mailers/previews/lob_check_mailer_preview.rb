# frozen_string_literal: true

class LobCheckMailerPreview < ActionMailer::Preview
  def initialize( params = {} )
    super( params )

    @lob_check = LobCheck.voided.last
  end

  def undeposited
    LobCheckMailer.with(lob_check: @lob_check).undeposited
  end

  def undeposited_organizers
    LobCheckMailer.with(lob_check: @lob_check).undeposited_organizers
  end

end
