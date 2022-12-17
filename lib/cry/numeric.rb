module Cry
  # Add some methods to Numeric using [Refinement](https://docs.ruby-lang.org/en/master/Refinement.html)
  # This module extends Ruby's Numeric with a specific scope using Refinement.
  # Avoid errors when calling Crystal's type conversion methods in Ruby.
  # @example
  #  class Foo
  #    using Cry::Numeric
  #    def bar(n)
  #      1.to_f32
  #      1.to_f32!
  #      1.to_f64
  #      1.to_f64!
  #      1.to_i
  #      1.to_i!
  #      1.to_i128
  #      1.to_i128!
  #      1.to_i16
  #      1.to_i16!
  #      1.to_i32
  #      1.to_i32!
  #      1.to_i64
  #      1.to_i64!
  #      1.to_i8
  #      1.to_i8!
  #      1.to_u
  #      1.to_u!
  #      1.to_u128
  #      1.to_u128!
  #      1.to_u16
  #      1.to_u16!
  #      1.to_u32
  #      1.to_u32!
  #      1.to_u64
  #      1.to_u64!
  #      1.to_u8
  #      1.to_u8!
  #      1.not_nil!
  #    end
  #  end
  module Numeric
    refine ::Numeric do
      def to_f32
        to_f
      end

      def to_f32!
        to_f
      end

      def to_f64
        to_f
      end

      def to_f64!
        to_f
      end

      # def to_i

      def to_i!
        to_i
      end

      def to_i128
        to_i
      end

      def to_i128!
        to_i
      end

      def to_i16
        to_i
      end

      def to_i16!
        to_i
      end

      def to_i32
        to_i
      end

      def to_i32!
        to_i
      end

      def to_i64
        to_i
      end

      def to_i64!
        to_i
      end

      def to_i8
        to_i
      end

      def to_i8!
        to_i
      end

      def to_u
        to_i
      end

      def to_u!
        to_i
      end

      def to_u128
        to_i
      end

      def to_u128!
        to_i
      end

      def to_u16
        to_i
      end

      def to_u16!
        to_i
      end

      def to_u32
        to_i
      end

      def to_u32!
        to_i
      end

      def to_u64
        to_i
      end

      def to_u64!
        to_i
      end

      def to_u8
        to_i
      end

      def to_u8!
        to_i
      end

      def not_nil!
        self
      end
    end
  end
end
