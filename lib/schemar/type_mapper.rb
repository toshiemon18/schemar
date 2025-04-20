# frozen_string_literal: true

require "bigdecimal"
require "date"

module Schemar
  # Rubyの型をOpenAPIの型/フォーマットにマッピングするヘルパー
  module OpenAPITypeMapper
    MAP = {
      String => {type: "string"},
      Integer => {type: "integer", format: "int64"},
      Float => {type: "number", format: "float"},
      BigDecimal => {type: "number", format: "double"}, # もしくはstringでformatを付けるか
      Schemar::Boolean => {type: "boolean"},
      Date => {type: "string", format: "date"},
      Time => {type: "string", format: "date-time"},
      DateTime => {type: "string", format: "date-time"},
      Array => {type: "array"},
      Hash => {type: "object"} # より具体的には additionalProperties なども考慮できる
    }.freeze

    def self.map(ruby_type)
      MAP[ruby_type] || {type: "object"} # 不明な型は object とする (要調整)
    end
  end
end
