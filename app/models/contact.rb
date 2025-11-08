class Contact < ApplicationRecord
  belongs_to :user, optional: true
  validates :name, presence: true, unless: :user_id?
  validates :email, presence: true, unless: :user_id?
  validates :message, presence: true
  validates :inquiry_type, presence: true

  enum :inquiry_type, {
    suggestion: 0,
    bug: 1,
    review: 2,
    account: 3,
    rules: 4,
    other: 5
  }
end
