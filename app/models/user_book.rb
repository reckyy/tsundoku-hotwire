# frozen_string_literal: true

class UserBook < ApplicationRecord
  belongs_to :user
  belongs_to :book
  has_many :headings, dependent: :destroy

  validates :user_id, uniqueness: { scope: :book_id }

  enum :status, { unread: 0, reading: 1, finished: 2 }, prefix: true

  acts_as_list scope: %i[user_id status]

  def swap_positions_with(item)
    transaction do
      item_position = item.position
      item.set_list_position(position, true)
      set_list_position(item_position, true)
    end
    true
  rescue ActiveRecord::ActiveRecordError
    false
  end

  def save_with_heading
    transaction do
      save!
      headings.create!(number: 1, title: '', memo_attributes: {})
    end
    true
  rescue ActiveRecord::ActiveRecordError
    false
  end

  def ordered_headings
    headings.sort_by(&:id)
  end
end
