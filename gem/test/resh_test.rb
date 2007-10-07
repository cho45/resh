require File.dirname(__FILE__) + '/test_helper.rb'

require "test/unit"
class ReshTest < Test::Unit::TestCase
	def test_require
		require "rubygems"
		assert_nothing_raised do
			require "resh/resh"
		end
	end
end
