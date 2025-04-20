# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
require "schemar"
require_relative "user"
require_relative "tag"

module Example
  class Post
    extend Schemar::SchemaDefinable

    # 投稿の基本情報
    attribute :id, type: Integer, required: true, description: "Post ID"
    attribute :title, type: String, required: true, description: "Post title"
    attribute :content, type: String, required: true, description: "Post content"
    attribute :status, type: String, required: true, description: "Publication status"
    enum :status, {
      draft: "draft",
      published: "published",
      archived: "archived"
    }
    attribute :type, type: Integer, required: true, description: "Post type"
    enum :type, {
      technology: 0,
      lifestyle: 1,
      business: 2,
      entertainment: 3
    }
    attribute :tags, type: Array, item_type: Tag, description: "Post tags"

    # 投稿のメタデータ
    attribute :author, type: User, required: true, description: "Post author"
    attribute :category, type: String, description: "Post category"

    # タイムスタンプ
    attribute :created_at, type: DateTime, required: true, description: "Post creation timestamp"
    attribute :updated_at, type: DateTime, required: true, description: "Last update timestamp"
    attribute :published_at, type: DateTime, description: "Publication timestamp"
  end
end
