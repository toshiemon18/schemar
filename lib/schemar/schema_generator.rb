# frozen_string_literal: true

require "yaml"
require "json"

module Schemar
  # スキーマ生成全体を管理するクラス
  class SchemaGenerator
    def initialize(target_classes)
      @target_classes = target_classes.select do |klass|
        klass.respond_to?(:generate_schema_definition)
      end
    end

    # components/schemas に対応するハッシュを生成
    def generate_components_schemas
      @target_classes.each_with_object({}) do |klass, schemas|
        class_name = klass.name.split("::").last # 名前空間を除去 (必要に応じて調整)
        schemas[class_name] = klass.generate_schema_definition
      end
    end

    # 完全なOpenAPIドキュメント(ハッシュ)を生成 (簡易版)
    def generate_openapi_doc(title: "Generated API", version: "1.0.0")
      {
        openapi: "3.0.0",
        info: {
          title: title,
          version: version
        },
        components: {
          schemas: generate_components_schemas
        }
        # paths: {} # 必要ならパス情報も追加
      }
    end

    # YAMLとして出力
    def write_yaml(path, title: "Generated API", version: "1.0.0")
      doc = generate_openapi_doc(title: title, version: version)
      # Ruby 3.1以降なら YAML.dump(doc, header: false) のようにヘッダを抑制可能
      # シンボルを文字列キーに変換してからdumpする
      File.write(path, JSON.parse(doc.to_json).to_yaml) # Hashのキーを文字列に確実にするため一手間
    end

    # JSONとして出力
    def write_json(path, title: "Generated API", version: "1.0.0")
      doc = generate_openapi_doc(title: title, version: version)
      File.write(path, JSON.pretty_generate(doc))
    end
  end
end
