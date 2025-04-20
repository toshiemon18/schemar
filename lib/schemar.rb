# frozen_string_literal: true

require_relative "schemar/version"
require_relative "schemar/boolean"
require_relative "schemar/type_mapper"
require_relative "schemar/schema_definable"
require_relative "schemar/schema_generator"

module Schemar
  class Error < StandardError; end
end
