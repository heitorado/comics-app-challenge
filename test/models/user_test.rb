require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should store the hash of favourited comics in a specific format" do
    favourite_comics_hash = { '1' => true, '2' => true, '3' => true }
    
    user = User.new
    user.favourite_comics = favourite_comics_hash

    assert user.save
    assert_equal favourite_comics_hash, User.first.favourite_comics
  end
end
