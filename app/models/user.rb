class User < ApplicationRecord
  serialize :favourite_comics, Hash
end
