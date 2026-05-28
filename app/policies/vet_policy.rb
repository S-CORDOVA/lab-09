class VetPolicy < ApplicationPolicy
  def index?
    admin? || vet? || owner?
  end

  def show?
    admin? || vet? || owner?
  end

  def create?
    admin?
  end

  def update?
    admin? || own_vet_record?
  end

  def destroy?
    admin?
  end

  def permitted_attributes
    if admin?
      [:first_name, :last_name, :email, :phone, :specialization, :user_id]
    elsif vet? && own_vet_record?
      [:first_name, :last_name, :email, :phone, :specialization]
    else
      []
    end
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if admin? || vet? || owner?
        scope.all
      else
        scope.none
      end
    end
  end

  private

  def own_vet_record?
    record.user_id == user.id
  end
end