# frozen_string_literal: true

require "find"

module Schemar
  module Commands
    class ModelFinder
      def self.find_models(directory)
        new(directory).find_models
      end

      def initialize(directory)
        @directory = File.expand_path(directory)
      end

      def find_models
        models = []
        Find.find(@directory) do |path|
          next unless path.end_with?(".rb")
          next if path.include?("spec/") || path.include?("test/")

          content = File.read(path)
          if content.include?("extend Schemar::SchemaDefinable")
            models << extract_model_class(path, content)
          end
        end
        models.compact
      end

      private

      def extract_model_class(path, content)
        # ファイルをrequire
        require path

        # ファイル内容からモジュールとクラスの定義を抽出
        modules = []
        content.each_line do |line|
          if (match = line.match(/^\s*module\s+(\w+)/))
            modules << match[1]
          elsif (match = line.match(/^\s*class\s+(\w+)/)) && modules.any?
            class_name = match[1]
            full_class_name = (modules + [class_name]).join("::")

            # クラスを取得
            begin
              klass = Object.const_get(full_class_name)
              return klass if klass.respond_to?(:schema_attributes)
            rescue NameError
              next
            end
          end
        end

        puts "Warning: Could not find module or class definition in #{path}"
        nil
      rescue LoadError, NameError => e
        puts "Warning: Could not load model from #{path}: #{e.message}"
        nil
      end
    end
  end
end
