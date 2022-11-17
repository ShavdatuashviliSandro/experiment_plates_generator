class ExperimentPlate < ApplicationRecord
  validates :plate_size, :number_of_replication, :sample, :reagent, presence: true

  belongs_to :user
end
