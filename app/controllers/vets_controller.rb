class VetsController < ApplicationController
  before_action :set_vet, only: [:show, :edit, :update, :destroy]

  def index
    @vets = policy_scope(Vet)
  end

  def show
    authorize @vet
  end

  def new
    @vet = Vet.new
    authorize @vet
  end

  def create
    @vet = Vet.new(vet_params)
    authorize @vet

    if @vet.save
      redirect_to @vet, notice: "Vet created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @vet
  end

  def update
    authorize @vet

    if @vet.update(vet_params)
      redirect_to @vet, notice: "Vet updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @vet

    @vet.destroy
    redirect_to vets_path, notice: "Vet deleted"
  end

  private

  def set_vet
    @vet = Vet.find(params[:id])
  end

  def vet_params
    params.require(:vet).permit(policy(@vet || Vet).permitted_attributes)
  end
end