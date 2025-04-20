# frozen_string_literal: true

require "spec_helper"
require "tempfile"

RSpec.describe Schemar::CLI do
  let(:temp_dir) { Dir.mktmpdir }
  let(:cli) { described_class.new }

  after do
    FileUtils.remove_entry(temp_dir)
  end

  describe "#generate" do
    before do
      # テスト用のモデルファイルを作成
      model_file = File.join(temp_dir, "user.rb")
      File.write(model_file, <<~RUBY)
        # frozen_string_literal: true
        require "schemar"

        module Example
          class User
            extend Schemar::SchemaDefinable
            attribute :name, type: String, required: true
            attribute :age, type: Integer
          end
        end
      RUBY

      # モデルファイルを読み込めるように$LOAD_PATHを設定
      $LOAD_PATH.unshift(temp_dir)
    end

    after do
      $LOAD_PATH.delete(temp_dir)
    end

    it "generates OpenAPI schema in YAML format" do
      output_file = File.join(temp_dir, "schema.yaml")
      cli.invoke(:generate, [temp_dir], {output: output_file, format: "yaml"})

      content = File.read(output_file)
      expect(content).to include("openapi: 3.0.0")
      expect(content).to include("title: Generated API")
      expect(content).to include("version: 1.0.0")
      expect(content).to include("User:")  # モジュール名は含まれない
    end

    it "generates OpenAPI schema in JSON format" do
      output_file = File.join(temp_dir, "schema.json")
      cli.invoke(:generate, [temp_dir], {output: output_file, format: "json"})

      content = File.read(output_file)
      expect(content).to include('"openapi": "3.0.0"')
      expect(content).to include('"title": "Generated API"')
      expect(content).to include('"version": "1.0.0"')
      expect(content).to include('"User":')  # モジュール名は含まれない
    end

    it "uses custom title and version" do
      output_file = File.join(temp_dir, "schema.yaml")
      cli.invoke(:generate, [temp_dir], {output: output_file, format: "yaml", title: "Custom API", version: "2.0.0"})

      content = File.read(output_file)
      expect(content).to include("title: Custom API")
      expect(content).to include("version: 2.0.0")
    end

    it "exits with error when no models are found" do
      empty_dir = Dir.mktmpdir
      expect {
        cli.invoke(:generate, [empty_dir])
      }.to raise_error(SystemExit)
      FileUtils.remove_entry(empty_dir)
    end

    it "exits with error when invalid format is specified" do
      expect {
        cli.invoke(:generate, [temp_dir], {format: "invalid"})
      }.to raise_error(SystemExit)
    end
  end

  describe "#version" do
    it "prints the version" do
      expect {
        cli.invoke(:version)
      }.to output(/Schemar \d+\.\d+\.\d+/).to_stdout
    end
  end
end
