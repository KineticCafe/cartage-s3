# -*- ruby encoding: utf-8 -*-
# frozen_string_literal: true

gem 'minitest'
require 'minitest/autorun'
require 'minitest/pretty_diff'
require 'minitest/focus'
require 'minitest/moar'
require 'minitest/bisect'
require 'minitest-bonus-assertions'

require 'cartage/minitest'

module Cartage::MinitestExtensions
  def enable_warnings
    $VERBOSE, verbose = false, $VERBOSE
    yield
  ensure
    $VERBOSE = verbose
  end

  Minitest::Test.send(:include, self)
end
