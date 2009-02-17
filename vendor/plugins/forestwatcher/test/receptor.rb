class Receptor
  require 'singleton'
  include Singleton
  
  attr_accessor :messages
  
  def initialize
    @messages = []
  end
  
  def method_missing(*attrs)
    self.messages << attrs
  end
end
