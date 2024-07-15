class Notification < ApplicationRecord
  include Noticed::Model
  belongs_to :recipient, polymorphic: true

  after_commit :notify, on: [:create, :update]

  scope :unread, ->{ where(read_at: nil) }
  scope :recent, ->{ order(created_at: :desc).limit(5) }

  private

  def notify
    NotificationJob.perform_later(self)
  end
end
