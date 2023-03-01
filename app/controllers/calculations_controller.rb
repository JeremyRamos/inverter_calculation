class CalculationsController < ApplicationController
  def new
  end

  def calculate
    if calculation_params[:total_wattage].present?
      inverter_size = calculate_inverter_size(calculation_params[:total_wattage].to_i)
      battery_size, hours = calculate_battery_size(calculation_params[:total_wattage].to_i, 0.8, 12)
      render turbo_stream: turbo_stream.replace('results', partial: 'results', locals: { inverter_size: inverter_size, battery_size: battery_size, hours: hours })
    else
      render turbo_stream: turbo_stream.remove('results')
    end
  end

  private

  def calculation_params
    params.require(:calculation).permit(:total_wattage)
  end

  def calculate_inverter_size(total_wattage)
    # total_wattage = tv_wattage.to_i + router_wattage.to_i
    # inverter_size = total_wattage / 0.8 # Assuming an 80% efficiency rate. An 80% efficient inverter will use (total_wattage / 0.8) Watts to produce total_wattage.
    inverter_size = total_wattage + (total_wattage * 0.20) # Select an appropriate inverter that has a power rating at least 20% larger than your calculated requirement
    inverter_size.ceil # Round up to the nearest integer
  end

  def calculate_battery_size(total_wattage, efficiency, voltage)
    power_required = total_wattage.to_i / efficiency # Assuming an 80% efficiency rate. An 80% efficient inverter will use (total_wattage / 0.8) Watts to produce total_wattage.
    # energy = total_wattage.to_i * time
    # amp_hours = energy / (efficiency * voltage)
    amp_hours = power_required / voltage # this is the ampere a 12 volt battery will require to produce the power_required

    # Remember that one should not aim to discharge the battery more than 50%.
    battery_capacity = 52 #105 / 2

    hours = battery_capacity / amp_hours # how long the size batter will provide power

    [amp_hours.ceil, hours.round(2)] # Round up to the nearest integer
  end
end
