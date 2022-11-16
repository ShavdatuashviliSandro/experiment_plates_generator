class CreateExperimentPlates < ActiveRecord::Migration[6.1]
  def change
    create_table :experiment_plates do |t|
      t.integer :plate_size, null: false
      t.string :sample, null: false
      t.string :reagent, null: false
      t.string :number_of_replication, null: false
      t.timestamps
    end
  end
end
