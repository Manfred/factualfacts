class Fact < ActiveRecord::Base
  named_scope :latest, :order => 'created_at DESC', :limit => 10
  validates_presence_of :body
end
