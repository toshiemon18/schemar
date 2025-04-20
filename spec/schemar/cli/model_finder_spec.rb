# frozen_string_literal: true

require "spec_helper"
require "tempfile"

RSpec.describe Schemar::Commands::ModelFinder do
  let(:temp_dir) { Dir.mktmpdir }
  let(:model_finder) { described_class.new(temp_dir) }

  after do
    FileUtils.remove_entry(temp_dir)
  end

  describe ".find_models" do
    it "finds models that extend SchemaDefinable" do
      # テスト用のモデルファイルを作成
      model_file = File.join(temp_dir, "user.rb")
      File.write(model_file, <<~RUBY)
        # frozen_string_literal: true
        require "schemar"

        module Example
          class User
            extend Schemar::SchemaDefinable
            attribute :name, type: String
          end
        end
      RUBY

      # モデルファイルを読み込めるように$LOAD_PATHを設定
      $LOAD_PATH.unshift(temp_dir)

      models = described_class.find_models(temp_dir)
      expect(models.size).to eq(1)
      expect(models.first.name).to eq("Example::User")

      $LOAD_PATH.delete(temp_dir)
    end

    it "ignores files that don't extend SchemaDefinable" do
      # SchemaDefinableを継承していないファイルを作成
      model_file = File.join(temp_dir, "not_a_model.rb")
      File.write(model_file, <<~RUBY)
        # frozen_string_literal: true
        class NotAModel
        end
      RUBY

      models = described_class.find_models(temp_dir)
      expect(models).to be_empty
    end

    it "ignores files in spec and test directories" do
      # specディレクトリにモデルファイルを作成
      spec_dir = File.join(temp_dir, "spec")
      Dir.mkdir(spec_dir)
      model_file = File.join(spec_dir, "user.rb")
      File.write(model_file, <<~RUBY)
        # frozen_string_literal: true
        require "schemar"

        module Example
          class User
            extend Schemar::SchemaDefinable
            attribute :name, type: String
          end
        end
      RUBY

      models = described_class.find_models(temp_dir)
      expect(models).to be_empty
    end

    it "handles nested modules correctly" do
      # ネストしたモジュールを含むモデルファイルを作成
      model_file = File.join(temp_dir, "deeply_nested.rb")
      File.write(model_file, <<~RUBY)
        # frozen_string_literal: true
        require "schemar"

        module Example
          module Nested
            module Very
              class DeepModel
                extend Schemar::SchemaDefinable
                attribute :name, type: String
              end
            end
          end
        end

        # モジュールを事前に定義
        module Example
          module Nested
            module Very
            end
          end
        end
      RUBY

      # モデルファイルを読み込めるように$LOAD_PATHを設定
      $LOAD_PATH.unshift(temp_dir)

      models = described_class.find_models(temp_dir)
      expect(models.size).to eq(1)
      expect(models.first.name).to eq("Example::Nested::Very::DeepModel")

      $LOAD_PATH.delete(temp_dir)
    end
  end

  describe "#extract_model_class" do
    it "extracts class from file with module" do
      content = <<~RUBY
        # frozen_string_literal: true
        require "schemar"

        module Example
          class User
            extend Schemar::SchemaDefinable
            attribute :name, type: String
          end
        end

        # モジュールを事前に定義
        module Example
        end
      RUBY

      # 一時ファイルを作成して読み込めるようにする
      temp_file = Tempfile.new(["test", ".rb"])
      temp_file.write(content)
      temp_file.close

      begin
        klass = model_finder.send(:extract_model_class, temp_file.path, content)
        expect(klass.name).to eq("Example::User")
      ensure
        temp_file.unlink
      end
    end

    it "returns nil when module or class is not found" do
      content = <<~RUBY
        # frozen_string_literal: true
        # No module or class definition
      RUBY

      klass = model_finder.send(:extract_model_class, "dummy_path", content)
      expect(klass).to be_nil
    end

    it "handles load errors gracefully" do
      content = <<~RUBY
        # frozen_string_literal: true
        require "non_existent_gem"

        module Example
          class User
            extend Schemar::SchemaDefinable
          end
        end
      RUBY

      klass = model_finder.send(:extract_model_class, "dummy_path", content)
      expect(klass).to be_nil
    end
  end
end
