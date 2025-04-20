# frozen_string_literal: true

require_relative "type_mapper"

module Schemar
  # クラスにスキーマ定義機能を追加するモジュール
  module SchemaDefinable
    # クラスがextendされたときに呼ばれる
    def self.extended(base)
      base.instance_variable_set(:@schema_attributes, {})
      base.instance_variable_set(:@schema_required, [])
    end

    # クラス変数のアクセサ
    attr_reader :schema_attributes, :schema_required

    # スキーマ属性を定義するDSLメソッド
    def attribute(name, type:, required: false, description: nil, example: nil, item_type: nil)
      @schema_attributes ||= {}
      @schema_required ||= []

      schema_info = Schemar::OpenAPITypeMapper.map(type).dup
      schema_info[:description] = description if description
      schema_info[:example] = example if example

      # 配列の場合、要素の型を指定
      if schema_info[:type] == "array"
        raise ArgumentError, "item_type must be specified for Array type attribute: #{name}" unless item_type
        schema_info[:items] = if item_type.is_a?(Class) && item_type.respond_to?(:generate_schema_definition) # 独自クラスの場合
          # ネストした独自クラスへの参照 ($ref)
          {"$ref" => "#/components/schemas/#{item_type.name.split("::").last}"}
        else
          # 基本型の場合
          Schemar::OpenAPITypeMapper.map(item_type)
        end
      # 独自クラスの場合 (Array以外)
      elsif type.respond_to?(:generate_schema_definition) && schema_info[:type] == "object"
        # $ref を使う
        schema_info = {"$ref" => "#/components/schemas/#{type.name.split("::").last}"}
      end

      @schema_attributes[name.to_sym] = schema_info
      @schema_required << name.to_sym if required
    end

    # enumを定義するDSLメソッド
    def enum(name, values)
      @schema_attributes ||= {}
      @schema_enums ||= {}

      # 属性が定義されているか確認
      unless @schema_attributes.key?(name.to_sym)
        raise ArgumentError, "Attribute '#{name}' must be defined before enum"
      end

      # enumの値を保存
      @schema_enums[name.to_sym] = values

      # 属性のスキーマ情報を更新
      schema_info = @schema_attributes[name.to_sym]
      schema_info[:enum] = values.values
      schema_info[:description] = "#{schema_info[:description]}\n\nEnum values:\n#{values.map { |k, v| "- #{k}: #{v}" }.join("\n")}"
    end

    # このクラスのOpenAPIスキーマ定義(ハッシュ)を生成
    def generate_schema_definition
      definition = {
        type: "object",
        properties: @schema_attributes || {}
      }
      definition[:required] = @schema_required.map(&:to_s).uniq.sort unless @schema_required.empty?
      definition
    end
  end
end
