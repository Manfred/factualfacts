class CreateFacts < ActiveRecord::Migration
  def self.up
    create_table :facts do |t|
      t.column :body, :text
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :facts
  end
end
