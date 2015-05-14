class CreateLocation < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :pid, null: false
      t.string :address, null: false
      t.float :longitude
      t.float :latitude
      t.timestamps
    end
  end
end
