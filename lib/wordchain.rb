require 'forwardable'
require 'wordchain/version'

module Wordchain
  class Dictionary
    attr_reader :entries

    extend Forwardable
    def_delegators :entries, :size, :include?, :empty?

    def initialize(entries: Dictionary.entries_from_system)
      @entries = entries
    end

    def refine_entries(&blk)
      Dictionary.new(entries: entries.select(&blk))
    end

    def self.entries_from_system
      File.
        readlines('/usr/share/dict/words').
        map(&:chomp)
    end
  end

  class Chain
    def initialize(start_with:, end_with:, dictionary:)
      raise "Starting and ending words in the chain must be same length" unless start_with.length == end_with.length

      @dictionary = dictionary.refine_entries { |word| word.length == start_with.length }

      @start_with = start_with
      @end_with = end_with
    end

    def construct
      current_word = @start_with
      final_word = @end_with
      chain = []

      until current_word == final_word
        chain << current_word
        candidates = candidates_for(current_word)
        next_word = candidates.min_by { |w| letters_different(w, final_word) }
        raise "no matching candidate words for #{current_word}" unless next_word
        current_word = next_word
      end

      chain << current_word
      chain
    end

    def candidates_for(word)
      @dictionary.entries.select do |dict_word|
        letters_different(word, dict_word) == 1
      end
    end

    def letters_different(first_word, second_word)
      differences = 0
      first_word.chars.each_with_index do |ch, i|
        if second_word.chars[i] != ch
          differences += 1
        end
      end
      differences
    end
  end
end
