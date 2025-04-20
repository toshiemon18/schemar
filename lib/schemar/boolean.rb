# frozen_string_literal: true

module Schemar
  # TrueClassとFalseClassのスーパークラスとして機能するBooleanクラス
  class Boolean
    def self.===(other)
      other.is_a?(TrueClass) || other.is_a?(FalseClass)
    end
  end
end
