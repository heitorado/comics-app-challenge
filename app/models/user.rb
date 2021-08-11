class User < ApplicationRecord
  serialize :favourite_comics, Hash

  scope :inactive_for_more_than, ->(period) { where('updated_at < ?', Time.current - period) }
end
