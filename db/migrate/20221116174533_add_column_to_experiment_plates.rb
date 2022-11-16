class AddColumnToExperimentPlates < ActiveRecord::Migration[6.1]
  def change
    add_column :experiment_plates, :number_of_replication, :integer

  end
end
