# frozen_string_literal: true

require "thor"
require_relative "cli/model_finder"

module Schemar
  class CLI < Thor
    desc "generate [DIRECTORY]", "Generate OpenAPI schema from Ruby models"
    option :output, type: :string, aliases: "-o", desc: "Output file path"
    option :format, type: :string, aliases: "-f", desc: "Output format (yaml/json), default: json", default: "json"
    option :directory, type: :string, aliases: "-d", desc: "Directory to search for models, default: .", default: "."
    option :title, type: :string, desc: "API title", default: "Generated API"
    option :version, type: :string, desc: "API version", default: "1.0.0"

    def generate(directory = ".")
      puts "Searching for models in #{directory}..."

      models = Commands::ModelFinder.find_models(directory)
      if models.empty?
        puts "No models found. Make sure your models extend Schemar::SchemaDefinable."
        exit 1
      end

      puts "Found #{models.size} models:"
      models.each { |model| puts "- #{model.name}" }

      generator = SchemaGenerator.new(models)
      output_path = options[:output] || "openapi.#{options[:format]}"

      case options[:format].downcase
      when "yaml"
        generator.write_yaml(output_path, title: options[:title], version: options[:version])
      when "json"
        generator.write_json(output_path, title: options[:title], version: options[:version])
      else
        puts "Invalid format: #{options[:format]}. Use 'yaml' or 'json'."
        exit 1
      end

      puts "Schema generated successfully: #{output_path}"
    end

    desc "version", "Show version"
    def version
      puts "Schemar #{Schemar::VERSION}"
    end
  end
end
