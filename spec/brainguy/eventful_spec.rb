require "rspec"
require "brainguy/eventful"
require "support/shared_examples_for_eventful_modules"

module Brainguy
  RSpec.describe Eventful do
    include_examples "an eventful module", Eventful
  end
end
