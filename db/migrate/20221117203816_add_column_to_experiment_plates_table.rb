class AddColumnToExperimentPlatesTable < ActiveRecord::Migration[6.1]
  def up
    add_reference :experiment_plates, :user, foreign_key: true

  end

  def down
    remove_reference :experiment_plates, :user
  end
end
