class GenerateExperimentPlatesController < ApplicationController
  before_action :init_service

  def index
    @pagy, @experiment_plates = pagy(@experiment_plates_service.list)
  end

  def show
    @result = @experiment_plates_service.generate_plate

  rescue StandardError
    render partial: 'layouts/error'
  end

  def new
    @experiment_plate = @experiment_plates_service.new
  end

  def create
    @experiment_plate = @experiment_plates_service.create

    @experiment_plate.save ? (redirect_to root_url, notice: '✓ Experiment created') : (render :new, status: :unprocessable_entity)
  end

  def edit
    @experiment_plate = @experiment_plates_service.edit
  end

  def update
    @experiment_plate = @experiment_plates_service.update

    @experiment_plate == true ? (redirect_to root_url, notice: '✓ Experiment updated') : (render :new, status: :unprocessable_entity)
  end

  def destroy
    @experiment_plate = @experiment_plates_service.delete
    redirect_to root_url, notice: '✓ Experiment deleted'
  end

  private

  def init_service
    @experiment_plates_service = GenerateExperimentPlates::ExperimentPlateService.new(User.first, params)
  end

end
