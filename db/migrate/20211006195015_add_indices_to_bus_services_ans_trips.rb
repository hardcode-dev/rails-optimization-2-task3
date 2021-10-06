class AddIndicesToBusServicesAnsTrips < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  
  def change
    add_index :buses_services, :bus_id, algorithm: :concurrently
    add_index :trips, [:from_id, :to_id], algorithm: :concurrently
    add_index :buses, :number, algorithm: :concurrently
  end
end
