module GenerateExperimentPlatesHelper
  def return_plate_number(plate)
    "Plate #{plate+1}"
  end

  def fill_row_wells(plate,row_number,column)
    if @result[plate][row_number][column].present?
      @result[plate][row_number][column].join(' X ')
    else
      'X'
    end
  end

  def return_columns(column_quantity)
    column_quantity + 1
  end
end
