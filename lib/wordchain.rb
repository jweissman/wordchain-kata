require 'forwardable'
require 'wordchain/version'

module Wordchain
  class Dictionary
    attr_reader :entries

    extend Forwardable
    def_delegators :entries, :select, :size, :include?, :empty?

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
    def initialize(start_with:, dictionary:)
      @dictionary = dictionary.refine_entries { |word| word.length == start_with.length }
      @start_with = start_with
    end

    def to(final_word)
      raise "Starting and ending words in the chain must be same length" unless @start_with.length == final_word.length

      candidates = candidates_for(@start_with)
      next_word = candidates.min_by { |w| letters_different(w, final_word) }
      raise "no matching candidate words for #{@start_with}" unless next_word

      if next_word == final_word
        [ @start_with, next_word ]
      else
        [ @start_with ] + Chain.new(start_with: next_word, dictionary: @dictionary).to(final_word)
      end
    end

    def candidates_for(word)
      @dictionary.select { |w| letters_different(word, w) == 1 }
    end

    def letters_different(first_word, second_word)
      zipped = first_word.chars.zip(second_word.chars)
      zipped.count { |(a,b)| a != b }
    end
  end
end
