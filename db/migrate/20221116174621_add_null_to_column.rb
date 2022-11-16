class AddNullToColumn < ActiveRecord::Migration[6.1]
  def change
    change_column_null :experiment_plates, :number_of_replication, :true
  end
end
