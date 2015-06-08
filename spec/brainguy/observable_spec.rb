require "rspec"
require "brainguy/observable"
require "support/shared_examples_for_eventful_modules"

module Brainguy
  RSpec.describe Observable do
    include_examples "an eventful module", Observable
  end
end
