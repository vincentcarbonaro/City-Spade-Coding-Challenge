class CreateLocation < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :pid, null: false
      t.string :address, null: false
      t.string :longitude
      t.string :latitude
      t.timestamps
    end
  end
end
