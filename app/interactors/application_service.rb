# Base class for the interactors in app/interactors (replaces Patterns::Service from rails-patterns).
#
#   SignUp.call(account, user)          # => the service instance
#   SignUp.call(account, user).result   # => whatever #call returned
class ApplicationService
  attr_reader :result

  def self.call(...)
    new(...).tap do |service|
      service.instance_variable_set(:@result, service.call)
    end
  end

  def call
    raise NotImplementedError
  end
end
