module Expgen
  module Randomizer
    extend self

    def repeat(number)
      if number == "*"
        ""
      elsif number == "+"
        yield
      elsif number
        number[:int].to_i.times.map { yield }.join
      else
        yield
      end
    end

    def randomize(tree)
      if tree.is_a?(Array)
        tree.map { |el| randomize(el) }.join
      elsif tree.is_a?(Hash)
        key, value = tree.keys.first, tree.values.first
        case key
        when :alternation then randomize(value.sample[:alt])
        when :group
          repeat(value[:repeat]) { randomize(value[:content]) }
        when :char_class
          repeat(value[:repeat]) { value[:content].map(&:chars).flatten.sample }
        when :shorthand_char_class
          repeat(value[:repeat]) { shorthand(value[:letter]) }
        else raise ArgumentError, "unknown key #{key}"
        end
      else
        tree.to_s
      end
    end

    def shorthand(letter)
      CharacterClass::ShorthandGroup.new(letter).chars
    end
  end
end
