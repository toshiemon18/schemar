# frozen_string_literal: true

require "spec_helper"

RSpec.describe Schemar::SchemaDefinable do
  let(:test_class) do
    klass = Class.new do
      extend Schemar::SchemaDefinable
    end
    klass.define_singleton_method(:name) { "TestClass" }
    klass
  end

  describe ".extended" do
    it "initializes class variables" do
      expect(test_class.instance_variable_get(:@schema_attributes)).to eq({})
      expect(test_class.instance_variable_get(:@schema_required)).to eq([])
    end
  end

  describe ".attribute" do
    context "with basic types" do
      before do
        test_class.attribute :name, type: String, required: true, description: "Name"
        test_class.attribute :age, type: Integer, required: false
      end

      it "defines attributes correctly" do
        attributes = test_class.schema_attributes
        expect(attributes[:name]).to eq({type: "string", description: "Name"})
        expect(attributes[:age]).to eq({type: "integer", format: "int64"})
      end

      it "sets required attributes correctly" do
        expect(test_class.schema_required).to eq([:name])
      end
    end

    context "with array type" do
      before do
        test_class.attribute :tags, type: Array, item_type: String
      end

      it "sets array item type correctly" do
        attributes = test_class.schema_attributes
        expect(attributes[:tags]).to eq({
          type: "array",
          items: {type: "string"}
        })
      end
    end

    context "with custom class type" do
      let(:nested_class) do
        klass = Class.new do
          extend Schemar::SchemaDefinable
          attribute :value, type: String
        end
        klass.define_singleton_method(:name) { "NestedClass" }
        klass
      end

      before do
        test_class.attribute :nested, type: nested_class
      end

      it "sets reference correctly" do
        attributes = test_class.schema_attributes
        expect(attributes[:nested]).to eq({
          "$ref" => "#/components/schemas/NestedClass"
        })
      end
    end

    context "with array of custom class type" do
      let(:item_class) do
        klass = Class.new do
          extend Schemar::SchemaDefinable
          attribute :value, type: String
        end
        klass.define_singleton_method(:name) { "ItemClass" }
        klass
      end

      before do
        test_class.attribute :items, type: Array, item_type: item_class
      end

      it "sets array item reference correctly" do
        attributes = test_class.schema_attributes
        expect(attributes[:items]).to eq({
          type: "array",
          items: {"$ref" => "#/components/schemas/ItemClass"}
        })
      end
    end
  end

  describe ".generate_schema_definition" do
    before do
      test_class.attribute :name, type: String, required: true
      test_class.attribute :age, type: Integer
    end

    it "generates schema definition correctly" do
      definition = test_class.generate_schema_definition
      expect(definition).to eq({
        type: "object",
        properties: {
          name: {type: "string"},
          age: {type: "integer", format: "int64"}
        },
        required: ["name"]
      })
    end
  end

  describe ".enum" do
    context "with string enum" do
      before do
        test_class.attribute :status, type: String, required: true, description: "Status"
        test_class.enum :status, {
          active: "active",
          inactive: "inactive",
          pending: "pending"
        }
      end

      it "adds enum values to schema" do
        attributes = test_class.schema_attributes
        expect(attributes[:status]).to eq({
          type: "string",
          description: "Status\n\nEnum values:\n- active: active\n- inactive: inactive\n- pending: pending",
          enum: ["active", "inactive", "pending"]
        })
      end
    end

    context "with integer enum" do
      before do
        test_class.attribute :type, type: Integer, required: true, description: "Type"
        test_class.enum :type, {
          admin: 0,
          user: 1,
          guest: 2
        }
      end

      it "adds enum values to schema" do
        attributes = test_class.schema_attributes
        expect(attributes[:type]).to eq({
          type: "integer",
          format: "int64",
          description: "Type\n\nEnum values:\n- admin: 0\n- user: 1\n- guest: 2",
          enum: [0, 1, 2]
        })
      end
    end

    context "when attribute is not defined" do
      it "raises ArgumentError" do
        expect {
          test_class.enum :undefined, {value: 1}
        }.to raise_error(ArgumentError, "Attribute 'undefined' must be defined before enum")
      end
    end
  end
end
