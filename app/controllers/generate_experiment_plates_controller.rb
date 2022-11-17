class GenerateExperimentPlatesController < ApplicationController
  before_action :init_service

  def index
    @pagy, @experiment_plates = pagy(ExperimentPlate.all)
  end

  def show
    @experiment_plate = ExperimentPlate.find(params[:id])
    plate_size = 96
    all_samples = [['სისხლი', 'უჯრედი', 'შარდი'], ['განავალი', 'ლორწო'],['ჩაი','ყავა']]
    all_reagents = [['რკინა', 'ქლორი'], ['ვერცხლი', 'ნატრიუმი'],['მჟავა','პავიდლო']]
    replicates = [12, 13,12]
    @result = generate_experiment_plate(plate_size, all_samples, all_reagents, replicates)
    @result
    binding.pry
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
    # sets the quantity of plate row's and column's
    plate_number = 0

    # validations
    set_plate_size(plate_size)
    parameters_are_valid?(all_samples,all_reagents,replicates)
    reagents_are_unique?(all_reagents)
    check_for_sample_repeating(all_samples)

    binding.pry
    @row_quantity.times do |index|
      next unless index < all_samples.length

      all_combinations = all_samples[index].product(all_reagents[index])

      # fill rows
      fill_empty_wells(all_combinations)

      # write combinations based on number of replicates
      replicates[index].times do # write combination in replicates time
        result[plate_number] << all_combinations
        if result[plate_number].length == @row_quantity
          result << []
          plate_number += 1
        end
      end
    end

    # calculate empty rows and fill them with nills if empty row is equal or above 0
    empty_rows = @row_quantity - result[0].length
    empty_rows.times do
      all_combinations = [nil] * @column_quantity
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

  def set_plate_size(plate_size)
    case plate_size
    when 96
      @row_quantity = 8
      @column_quantity = 12
    when 384
      @row_quantity = 16
      @column_quantity = 24
    else
      @row_quantity = 0
      @column_quantity = 0
      @error_text = 'We dont have plate of this size'
      render partial: 'layouts/error'
    end
  end

  def fill_empty_wells(all_combinations)
    empty_well_quantity = @column_quantity - all_combinations.length
    empty_well_quantity.times do
      all_combinations << nil
    end
  end

  def reagents_are_unique?(all_reagents)
    list = []
    reagents_quantity = all_reagents.length
    reagents_quantity.times do |index|
      list += all_reagents[index]
    end
    list.length == list.uniq.length
  end

  def parameters_are_valid?(all_samples, all_reagents, replicates)
    all_samples.length != all_reagents.length || all_reagents.length != replicates.length ? false : true
  end

  def check_for_sample_repeating(all_samples)
    samples_quantity = all_samples.length
    is_unique_samples = false
    samples_quantity.times do |index|
      is_unique_samples = all_samples[index].length == all_samples[index].uniq.length
      unless is_unique_samples
        break
      end
    end
    is_unique_samples
  end

end
