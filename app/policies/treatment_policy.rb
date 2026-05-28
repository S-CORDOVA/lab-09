class TreatmentPolicy < ApplicationPolicy
  def create?
    admin? || assigned_vet?
  end

  def new?
    create?
  end

  def update?
    admin? || assigned_vet?
  end

  def edit?
    update?
  end

  def destroy?
    admin? || assigned_vet?
  end

  def permitted_attributes
    if admin? || assigned_vet?
      [:name, :medication, :dosage, :clinical_notes, :administered_at]
    else
      []
    end
  end

  private

  def assigned_vet?
    record.appointment&.vet&.user_id == user.id
  end
end