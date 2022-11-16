class GenerateExperimentPlatesController < ApplicationController
  before_action :init_service

  def index
    @pagy, @experiment_plates = pagy(ExperimentPlate.all)
  end

  def show
    @experiment_plate = ExperimentPlate.find(params[:id])
    plate_size = 96
    all_samples = [['სისხლი', 'უჯრედი', 'შარდი'], ['განავალი', 'ლორწო']]
    all_reagents = [['რკინა', 'ქლორი'], ['ვერცხლი', 'ნატრიუმი']]
    replicates = [24, 9]
    @result = generate_experiment_plate(plate_size, all_samples, all_reagents, replicates)
    @result
    # binding.pry
  end

  def new
    @experiment_plate = ExperimentPlate.new
  end

  def create
    @experiment_plate = ExperimentPlate.new(experiment_params)
    if @experiment_plate.save
      redirect_to root_url, notice: 'წარმატებით შეიქმნა'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def generate_experiment_plate(plate_size,all_samples,all_reagents,replicates)
    result = [
      []
    ]

    case plate_size
    when 96
      row_quantity = 8
      column_quantity = 12
    when 384
      row_quantity = 16
      column_quantity = 24
    else
      row_quantity = 0
      column_quantity = 0
      puts 'We dont have plates of this size'
    end
    plate_number = 0

    row_quantity.times do |index|
      next unless index < all_samples.length

      all_combinations = all_samples[index].product(all_reagents[index])

      empty_well_quantity = column_quantity - all_combinations.length
      empty_well_quantity.times do
        all_combinations << nil
      end

      # all_combinations return one line of all the combination

      # write combinations based on number of replicates
      replicates[index].times do # write combination in replicates time
        result[plate_number] << all_combinations
        if result[plate_number].length == row_quantity
          result << []
          plate_number += 1
        end

      end
    end

    # calculate empty rows and fill them with nills if empty row is equal or above 0
    empty_rows = row_quantity - result[0].length
    empty_rows.times do
      all_combinations = [nil] * column_quantity
      result[0] << all_combinations
    end

    result

  end
  private

  def init_service
    @experiment_plates_service = GenerateExperimentPlates::ExperimentPlateService.new(@current_user)
  end

  def experiment_params
    params.require(:experiment_plate).permit(:plate_size, :samples, :reagents, :number_of_replication)
  end

end
