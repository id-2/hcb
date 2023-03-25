# frozen_string_literal: true

# == Schema Information
#
# Table name: bulletins
#
#  id           :bigint           not null, primary key
#  published_at :datetime
#  status       :integer          default("drafted"), not null
#  title        :string
#  type         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  author_id    :bigint
#
# Indexes
#
#  idx_bulletins_on_type_and_status_and_published_at_and_author_id  (type,status,published_at,author_id)
#  index_bulletins_on_author_id                                     (author_id)
#
class Bulletin < ApplicationRecord
  belongs_to :author, class_name: "User", optional: true

  enum status: { drafted: 0, published: 1 }

  validates :title, presence: true

  has_rich_text :content

  def self.policy_class
    BulletinPolicy
  end

  def visible_to?(user)
    published? || user&.admin?
  end

end
