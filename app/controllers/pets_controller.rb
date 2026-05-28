class PetsController < ApplicationController
  before_action :set_pet, only: [:show, :edit, :update, :destroy]

  def index
    @pets = policy_scope(Pet).includes(:owner)
  end

  def show
    authorize @pet
  end

  def new
    @pet = Pet.new
    authorize @pet
  end

  def create
    @pet = Pet.new(pet_params)
    authorize @pet

    if current_user.owner?
      @pet.owner = current_user.owner
    end

    if @pet.save
      redirect_to @pet, notice: "Pet created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @pet
  end

  def update
    authorize @pet

    if @pet.update(pet_params)
      redirect_to @pet, notice: "Pet updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @pet

    @pet.destroy
    redirect_to pets_path, notice: "Pet deleted"
  end

  private

  def set_pet
    @pet = Pet.find(params[:id])
  end

  def pet_params
    params.require(:pet).permit(policy(@pet || Pet).permitted_attributes)
  end
end