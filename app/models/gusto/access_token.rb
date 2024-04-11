# == Schema Information
#
# Table name: gusto_access_tokens
#
#  id            :bigint           not null, primary key
#  access_token  :string           not null
#  expires_at    :datetime         not null
#  refresh_token :string           not null
#
module Gusto
  class AccessToken < ApplicationRecord
  end
end
