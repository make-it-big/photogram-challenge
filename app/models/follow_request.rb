# == Schema Information
#
# Table name: follow_requests
#
#  id           :bigint           not null, primary key
#  status       :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  recipient_id :integer
#  sender_id    :integer
#
class FollowRequest < ApplicationRecord

  belongs_to :sender, class_name: "User", foreign_key: "sender_id", primary_key: "id"
  belongs_to :recipient, class_name: "User", foreign_key: "recipient_id", primary_key: "id"

  validates :status, inclusion: { in: ["pending", "accepted", "rejected"] }
  validates :recipient_id, uniqueness: { scope: :sender_id }

  validate :sender_and_recipient_are_different

  def sender_and_recipient_are_different
    if self.sender_id == self.recipient_id
      self.errors.add(:recipient_id, "can't be the same as sender")
    end
  end
end
