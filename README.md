# Schemar

A Ruby library for automatically generating OpenAPI JSON schemas from Ruby classes.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'schemar'
```

And then execute:

```bash
bundle install
```

## Usage

### Basic Usage

1. Create a model class and extend `SchemaDefinable`:

```ruby
class User
  extend Schemar::SchemaDefinable

  # Define basic type attributes
  attribute :id, type: Integer, required: true, description: "User ID"
  attribute :name, type: String, required: true, description: "User name"
  attribute :is_active, type: Boolean, required: true, description: "Account status"
  attribute :birth_date, type: Date, description: "Date of birth"
  attribute :created_at, type: DateTime, required: true, description: "Creation timestamp"

  # Define array type attributes
  attribute :tags, type: Array, item_type: String, description: "User tags"

  # Define nested objects
  attribute :address, type: Address, description: "User address"
end
```

2. Generate the schema:

```ruby
generator = Schemar::SchemaGenerator.new([User])
generator.write_json("openapi.json", title: "User API", version: "1.0.0")
```

### Supported Types

The following types are supported:

- `String`
- `Integer`
- `Float`
- `BigDecimal`
- `Boolean` (only available within classes that extend SchemaDefinable)
- `Date`
- `Time`
- `DateTime`
- `Array` (specify element type with item_type)
- `Hash`

### Enum Definition

```ruby
class Post
  extend Schemar::SchemaDefinable

  attribute :status, type: String, required: true, description: "Post status"
  enum :status, {
    draft: "draft",
    published: "published",
    archived: "archived"
  }
end
```

## Development

After checking out the repo, run:

```bash
bin/setup
```

To run tests:

```bash
bundle exec rspec
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Schemar project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](CODE_OF_CONDUCT.md).
