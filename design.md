# Schema Definition機能の設計解説

## 概要

`schema_definition.rb`はRubyで書かれたコードであり、RubyクラスからOpenAPI仕様のJSONスキーマを自動生成するためのライブラリです。このライブラリを使用することで、Rubyのクラス定義からRESTful APIドキュメント用のスキーマを容易に生成できます。

## 主要コンポーネント

### 1. OpenAPITypeMapper

Rubyの型をOpenAPI仕様の型やフォーマットにマッピングするためのヘルパーモジュールです。

- `MAP`定数: RubyのクラスとOpenAPIの型定義の対応関係を定義
- `map`メソッド: 与えられたRubyの型に基づいてOpenAPI型情報を返す

例えば、`String`は`{type: 'string'}`に、`Date`は`{type: 'string', format: 'date'}`にマッピングされます。

### 2. SchemaDefinable

クラスにスキーマ定義機能を追加するモジュールです。

- このモジュールをクラスに`extend`することで、そのクラスにスキーマ定義用のDSLが追加される
- `attribute`メソッド: クラスの属性を定義するDSLメソッド
  - 名前、型、必須かどうか、説明、例、配列要素の型などを指定可能
- `generate_schema_definition`メソッド: クラスのOpenAPIスキーマ定義を生成する

### 3. SchemaGenerator

スキーマ生成全体を管理するクラスです。

- `initialize`: スキーマ生成対象のクラスを指定
- `generate_components_schemas`: OpenAPIの`components/schemas`部分を生成
- `generate_openapi_doc`: 完全なOpenAPIドキュメントを生成
- `write_yaml`/`write_json`: 生成したスキーマをファイルに出力

## 特徴

1. **宣言的定義**: DSLを用いて直感的にスキーマを定義できる
2. **型マッピング**: Rubyの型とOpenAPI仕様の型を自動的にマッピング
3. **ネスト対応**: オブジェクトのネストや配列の要素型を指定可能
4. **出力形式**: YAML形式とJSON形式の両方でスキーマを出力可能

## 使用例

`usage.rb`に示されているように、クラスに`SchemaDefinable`をextendし、`attribute`メソッドで属性を定義します。そして`SchemaGenerator`を使ってOpenAPIスキーマを生成します。
