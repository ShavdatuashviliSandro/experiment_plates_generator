class GenerateExperimentPlatesController < ApplicationController
  before_action :init_service
  attr_accessor :validation_confirms

  def index
    @pagy, @experiment_plates = pagy(ExperimentPlate.all)
  end

  def destroy
    @experiment_plate = ExperimentPlate.find(params[:id])
    @experiment_plate.destroy
  end

  def show
    @experiment_plate = ExperimentPlate.find(params[:id])
    # all_samples = [['სისხლი', 'უჯრედი', 'შარდი'], ['განავალი', 'ლორწო'], ['ჩაი', 'ყავა']]
    all_reagents = [['რკინა', 'ქლორი'], ['ვერცხლი', 'ნატრიუმი'], ['მჟავა', 'პავიდლო']]

    plate_size = return_data_for_plate_size(@experiment_plate)
    all_samples = return_data_for_experiment(@experiment_plate.sample)
    all_reagents = return_data_for_experiment(@experiment_plate.reagent)
    replicates = return_data_for_replicates(@experiment_plate)
    @result = generate_experiment_plate(plate_size, all_samples, all_reagents, replicates)
    @result
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

  def generate_experiment_plate(plate_size, all_samples, all_reagents, replicates)
    result = [
      []
    ]

    plate_number = 0

    # sets the quantity of plate row's and column's

    # validations
    @validation_confirms = []

    set_plate_size(plate_size)
    @validation_confirms << parameters_are_valid?(all_samples, all_reagents, replicates)
    @validation_confirms << reagents_are_unique?(all_reagents)
    @validation_confirms << check_for_sample_repeating(all_samples)

    # if we have validate error in list
    if !validation_confirms.any?(false)
      @row_quantity.times do |index|
        next unless index < all_samples.length

        all_combinations = all_samples[index].product(all_reagents[index])

        # fill rows
        fill_empty_wells(all_combinations)

        # write combinations based on number of replicates
        replicates[index].times do
          # write combination in replicates time
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
    else
      render partial: 'layouts/error'
    end


  end

  private

  def init_service
    @experiment_plates_service = GenerateExperimentPlates::ExperimentPlateService.new(@current_user)
  end

  def experiment_params
    params.require(:experiment_plate).permit(:plate_size, :sample, :reagent, :number_of_replication)
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
      validation_confirms << false
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

  def return_data_for_replicates(experiment)
    replicates = []
    replicates_string = experiment.number_of_replication.split(',')
    replicates_string.length.times do |replicate_number|
      replicates << replicates_string[replicate_number].to_i
    end
    replicates
  end

  def return_data_for_plate_size(experiment)
    experiment.plate_size
  end

  def return_data_for_experiment(experiment)
    experiment
    data = []
    experiment = experiment.split(' | ')
    experiment.length.times do |index|
      single_sample=experiment[index].split
      data << single_sample
    end
    data

  end
end
