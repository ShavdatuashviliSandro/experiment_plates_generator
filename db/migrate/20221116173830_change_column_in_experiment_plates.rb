class ChangeColumnInExperimentPlates < ActiveRecord::Migration[6.1]
  def change
    remove_column :experiment_plates, :number_of_replication
  end
end
