class IndexForeignKeysInTrips < ActiveRecord::Migration[5.2]
  def change
    add_index :trips, [:bus_id, :from_id, :to_id]
  end
end
