# frozen_string_literal: true

require "spec_helper"

RSpec.describe Schemar::OpenAPITypeMapper do
  describe ".map" do
    it "maps String type correctly" do
      expect(described_class.map(String)).to eq({type: "string"})
    end

    it "maps Integer type correctly" do
      expect(described_class.map(Integer)).to eq({type: "integer", format: "int64"})
    end

    it "maps Float type correctly" do
      expect(described_class.map(Float)).to eq({type: "number", format: "float"})
    end

    it "maps BigDecimal type correctly" do
      expect(described_class.map(BigDecimal)).to eq({type: "number", format: "double"})
    end

    it "maps Boolean type correctly" do
      expect(described_class.map(Schemar::Boolean)).to eq({type: "boolean"})
    end

    it "maps Date type correctly" do
      expect(described_class.map(Date)).to eq({type: "string", format: "date"})
    end

    it "maps Time type correctly" do
      expect(described_class.map(Time)).to eq({type: "string", format: "date-time"})
    end

    it "maps DateTime type correctly" do
      expect(described_class.map(DateTime)).to eq({type: "string", format: "date-time"})
    end

    it "maps Array type correctly" do
      expect(described_class.map(Array)).to eq({type: "array"})
    end

    it "maps Hash type correctly" do
      expect(described_class.map(Hash)).to eq({type: "object"})
    end

    it "maps unknown types as object" do
      expect(described_class.map(Object)).to eq({type: "object"})
    end
  end
end
