require 'rspec'
require 'shoulda'
require 'paperclip-swift-swauth'

class Dummy
  include Paperclip::Storage::SwiftSwauth
  attr_accessor :queued_for_write, :queued_for_delete
end
