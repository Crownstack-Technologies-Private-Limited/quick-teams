require "test_helper"

# Same contract as the Patterns::Service it replaces.
class ApplicationServiceTest < ActiveSupport::TestCase
  class Adder < ApplicationService
    def initialize(a, b, scale: 1)
      @a, @b, @scale = a, b, scale
    end

    def call
      (@a + @b) * @scale
    end
  end

  test ".call returns the service with #call's return value as result" do
    service = Adder.call(2, 3)
    assert_instance_of Adder, service
    assert_equal 5, service.result
  end

  test "positional and keyword arguments reach initialize" do
    assert_equal 50, Adder.call(2, 3, scale: 10).result
  end

  test "a subclass without #call raises NotImplementedError" do
    assert_raises(NotImplementedError) { Class.new(ApplicationService).call }
  end

  test "every interactor uses it" do
    Rails.application.eager_load!
    assert_operator ApplicationService.descendants.size, :>=, 41
  end
end
