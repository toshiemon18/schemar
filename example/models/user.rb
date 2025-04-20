# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
require "schemar"

module Example
  class User
    extend Schemar::SchemaDefinable

    # ユーザーの基本情報
    attribute :id, type: Integer, required: true, description: "User ID"
    attribute :username, type: String, required: true, description: "Username"
    attribute :email, type: String, required: true, description: "Email address"
    attribute :first_name, type: String, description: "First name"
    attribute :last_name, type: String, description: "Last name"
    attribute :birth_date, type: Date, description: "Date of birth"

    # アカウント情報
    attribute :created_at, type: DateTime, required: true, description: "Account creation timestamp"
    attribute :updated_at, type: DateTime, required: true, description: "Last update timestamp"
    attribute :is_active, type: Boolean, required: true, description: "Account status"

    # 設定情報
    attribute :settings, type: Hash, description: "User preferences and settings"
    attribute :roles, type: Array, item_type: String, description: "User roles"
  end
end
