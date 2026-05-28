class PetPolicy < ApplicationPolicy
  def index?
    admin? || vet? || owner?
  end

  def show?
    admin? || vet? || own_pet?
  end

  def create?
    admin? || owner?
  end

  def update?
    admin? || own_pet?
  end

  def destroy?
    admin? || own_pet?
  end

  def permitted_attributes
    if admin?
      [:name, :species, :breed, :date_of_birth, :weight, :owner_id, :photo]
    elsif owner?
      [:name, :species, :breed, :date_of_birth, :weight, :photo]
    else
      []
    end
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if admin? || vet?
        scope.all
      elsif owner?
        scope.joins(:owner).where(owners: { user_id: user.id })
      else
        scope.none
      end
    end
  end

  private

  def own_pet?
    record.owner&.user_id == user.id
  end
end