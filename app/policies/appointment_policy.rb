class AppointmentPolicy < ApplicationPolicy
  def index?
    admin? || vet? || owner?
  end

  def show?
    admin? || assigned_vet? || own_pet_appointment?
  end

  def create?
    admin? || vet? || owner?
  end

  def update?
    admin? || assigned_vet? || own_pet_appointment?
  end

  def destroy?
    admin? || assigned_vet? || own_pet_appointment?
  end

  def permitted_attributes
    if admin?
      [:pet_id, :vet_id, :date, :reason, :status]
    elsif owner?
      [:vet_id, :date, :reason, :status]
    elsif vet?
      [:date, :reason, :status]
    else
      []
    end
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if admin?
        scope.all
      elsif vet?
        scope.joins(:vet).where(vets: { user_id: user.id })
      elsif owner?
        scope.joins(pet: :owner).where(owners: { user_id: user.id })
      else
        scope.none
      end
    end
  end

  private

  def assigned_vet?
    record.vet&.user_id == user.id
  end

  def own_pet_appointment?
    record.pet&.owner&.user_id == user.id
  end
end