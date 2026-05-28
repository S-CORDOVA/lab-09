class AppointmentsController < ApplicationController
  before_action :set_appointment, only: [:show, :edit, :update, :destroy]

  def index
    @appointments = policy_scope(Appointment).includes(:pet, :vet)
  end

  def show
    authorize @appointment
    @treatments = @appointment.treatments.with_rich_text_clinical_notes
  end

  def new
    @appointment = Appointment.new
    authorize @appointment
  end

  def create
    @appointment = Appointment.new(appointment_params)
    authorize @appointment

    if @appointment.save
      redirect_to @appointment, notice: "Appointment created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @appointment
  end

  def update
    authorize @appointment

    if @appointment.update(appointment_params)
      redirect_to @appointment, notice: "Appointment updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @appointment

    @appointment.destroy
    redirect_to appointments_path, notice: "Appointment deleted"
  end

  private

  def set_appointment
    @appointment = Appointment.find(params[:id])
  end

  def appointment_params
    params.require(:appointment).permit(policy(@appointment || Appointment).permitted_attributes)
  end
end