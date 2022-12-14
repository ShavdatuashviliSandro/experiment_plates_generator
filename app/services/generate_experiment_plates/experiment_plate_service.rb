module GenerateExperimentPlates

  class ExperimentPlateService
    attr_accessor :current_user, :params

    def initialize(current_user, params)
      @current_user = current_user
      @params = params
    end

    def list
      ExperimentPlate.all.order(created_at: :desc)
    end

    def generate_plate
      find_record

      # gets data from forms and returns data for generating plates
      plate_size = return_data_for_plate_size(@experiment_plate)
      all_samples = return_data_for_experiment(@experiment_plate.sample)
      all_reagents = return_data_for_experiment(@experiment_plate.reagent)
      replicates = return_data_for_replicates(@experiment_plate)

      @result = generate_experiment_plate(plate_size, all_samples, all_reagents, replicates)
    end

    def new
      ExperimentPlate.new
    end

    def create
      ExperimentPlate.create(experiment_params)
    end

    def edit
      find_record
    end

    def update
      find_record.update(experiment_params)
    end

    def delete
      find_record.destroy
    end

    private

    def experiment_params
      params.require(:experiment_plate).permit(:plate_size, :sample, :reagent, :number_of_replication)
            .with_defaults(user_id: current_user.id)
    end

    def find_record
      @experiment_plate = ExperimentPlate.find(params[:id])
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
        @validation_confirms << false
      end
    end

    def return_data_for_plate_size(experiment)
      experiment.plate_size
    end

    def return_data_for_experiment(experiment)
      data = []
      experiment = experiment.split(' / ')
      # every element of experiment pushes in data array
      experiment.length.times do |index|
        single_sample = experiment[index].split
        data << single_sample
      end

      data
    end

    def return_data_for_replicates(experiment)
      replicates = []
      replicates_string = experiment.number_of_replication.split(',')
      # every element of replicates pushes in replicates array
      replicates_string.length.times do |replicate_number|
        replicates << replicates_string[replicate_number].to_i
      end
      replicates
    end

    def generate_experiment_plate(plate_size, all_samples, all_reagents, replicates)
      result = [
        []
      ]
      plate_number = 0

      # sets rows and columns quantity and checks for validations
      @validation_confirms = []
      check_for_validations(plate_size, all_samples, all_reagents, replicates)

      # raises error and renders error page if we have validate error in list
      raise 'You have experiment with wrong data' unless @validation_confirms.none?(false)

      # starting loop for filling rows
      @row_quantity.times do |index|
        # loop is starting while simples length is smaller than rows in tables
        next unless index < all_samples.length

        # every possible combination of reagents and samples
        all_combinations = all_samples[index].product(all_reagents[index])

        # fill row's empty wells
        fill_empty_wells(all_combinations)

        # write combinations based on number of replicates
        replicates[index].times do
          # write combination in plate
          result[plate_number] << all_combinations
          # if plate rows is full creating new plate
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

    def check_for_validations(plate_size, all_samples, all_reagents, replicates)
      set_plate_size(plate_size)
      @validation_confirms << parameters_are_valid?(all_samples, all_reagents, replicates)
      @validation_confirms << reagents_are_unique?(all_reagents)
      @validation_confirms << check_for_sample_repeating(all_samples)
    end

    def fill_empty_wells(all_combinations)
      empty_well_quantity = @column_quantity - all_combinations.length
      empty_well_quantity.times do
        all_combinations << nil
      end
    end

    def parameters_are_valid?(all_samples, all_reagents, replicates)
      all_samples.length != all_reagents.length || all_reagents.length != replicates.length ? false : true
    end

    def reagents_are_unique?(all_reagents)
      reagents = []

      # push every element of reagents in array
      reagents_quantity = all_reagents.length
      reagents_quantity.times do |index|
        reagents += all_reagents[index]
      end

      # check with uniqueness
      reagents.length == reagents.uniq.length
    end

    def check_for_sample_repeating(all_samples)
      is_unique_samples = false

      # this method checks every sample elements in one array and stops when is_unique_samples array became true
      samples_quantity = all_samples.length
      samples_quantity.times do |index|
        is_unique_samples = all_samples[index].length == all_samples[index].uniq.length
        break unless is_unique_samples
      end
      is_unique_samples
    end
  end
end
