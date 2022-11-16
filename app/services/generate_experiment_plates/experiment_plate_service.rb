module GenerateExperimentPlates

  class ExperimentPlateService
    attr_reader :current_user, :result

    def initialize(current_user)
      @current_user = current_user
      @result = OpenStruct.new(success?: false, experiment_plate: ExperimentPlate.new)
    end

    def list
      ExperimentPlate.all
    end

    def new
      result
    end

    def create(params)
      result.tap do |r|
        r.experiment_plate = ExperimentPlate.new(params)
        r.send('success?=', r.experiment_plate.save)
      end
    end

    private

    def find_record(id)
      result.experiment_plate = ExperimentPlate.find(id)
      result
    end
  end
end
