# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
require "schemar"
require_relative "user"

module Example
  class Tag
    extend Schemar::SchemaDefinable

    attribute :name, type: String, required: true
  end
end
