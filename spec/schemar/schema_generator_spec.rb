# frozen_string_literal: true

require "spec_helper"
require "tempfile"

RSpec.describe Schemar::SchemaGenerator do
  let(:test_class) do
    klass = Class.new do
      extend Schemar::SchemaDefinable
      attribute :name, type: String, required: true
      attribute :age, type: Integer
    end
    klass.define_singleton_method(:name) { "TestClass" }
    klass
  end

  let(:enum_class) do
    klass = Class.new do
      extend Schemar::SchemaDefinable
      attribute :status, type: String, required: true, description: "Status"
      enum :status, {
        active: "active",
        inactive: "inactive"
      }
      attribute :type, type: Integer, required: true, description: "Type"
      enum :type, {
        admin: 0,
        user: 1
      }
    end
    klass.define_singleton_method(:name) { "EnumClass" }
    klass
  end

  let(:generator) { described_class.new([test_class]) }
  let(:enum_generator) { described_class.new([enum_class]) }

  describe "#generate_components_schemas" do
    it "generates schema definitions for classes" do
      schemas = generator.generate_components_schemas
      expect(schemas).to have_key("TestClass")
      expect(schemas["TestClass"]).to include(
        type: "object",
        properties: {
          name: {type: "string"},
          age: {type: "integer", format: "int64"}
        },
        required: ["name"]
      )
    end

    it "generates schema definitions with enum values" do
      schemas = enum_generator.generate_components_schemas
      expect(schemas).to have_key("EnumClass")
      expect(schemas["EnumClass"]).to include(
        type: "object",
        properties: {
          status: {
            type: "string",
            description: "Status\n\nEnum values:\n- active: active\n- inactive: inactive",
            enum: ["active", "inactive"]
          },
          type: {
            type: "integer",
            format: "int64",
            description: "Type\n\nEnum values:\n- admin: 0\n- user: 1",
            enum: [0, 1]
          }
        },
        required: ["status", "type"]
      )
    end
  end

  describe "#generate_openapi_doc" do
    it "generates OpenAPI document" do
      doc = generator.generate_openapi_doc(title: "Test API", version: "1.0.0")
      expect(doc).to include(
        openapi: "3.0.0",
        info: {
          title: "Test API",
          version: "1.0.0"
        },
        components: {
          schemas: {
            "TestClass" => {
              type: "object",
              properties: {
                name: {type: "string"},
                age: {type: "integer", format: "int64"}
              },
              required: ["name"]
            }
          }
        }
      )
    end
  end

  describe "#write_yaml" do
    it "generates YAML file" do
      tempfile = Tempfile.new("test_schema")
      generator.write_yaml(tempfile.path, title: "Test API", version: "1.0.0")
      content = File.read(tempfile.path)
      expect(content).to include("openapi: 3.0.0")
      expect(content).to include("title: Test API")
      expect(content).to include("version: 1.0.0")
      tempfile.close
      tempfile.unlink
    end
  end

  describe "#write_json" do
    it "generates JSON file" do
      tempfile = Tempfile.new("test_schema")
      generator.write_json(tempfile.path, title: "Test API", version: "1.0.0")
      content = File.read(tempfile.path)
      expect(content).to include('"openapi": "3.0.0"')
      expect(content).to include('"title": "Test API"')
      expect(content).to include('"version": "1.0.0"')
      tempfile.close
      tempfile.unlink
    end
  end
end
