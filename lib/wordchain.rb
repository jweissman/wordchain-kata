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
    attr_reader :root_word, :dictionary
    def initialize(root_word:, dictionary:)
      @root_word = root_word
      @dictionary = dictionary.refine_entries do |word|
        word.length == root_word.length
      end
    end

    def to(final_word)
      unless root_word.length == final_word.length
        raise "Starting and ending words in the chain must be same length"
      end

      construct!(target: final_word)
    end

    private
    def construct!(target:)
      next_word = best_candidate_for root_word, target: target

      unless next_word
        raise "No matching candidate words for #{root_word}"
      end

      subchain_from next_word, target: target
    end

    def subchain_from(word, target:)
      if word == target
        [ root_word, word ]
      else
        subchain = Chain.new(root_word: word, dictionary: dictionary)
        [ root_word ] + subchain.to(target)
      end
    end

    def best_candidate_for(word, target:)
      candidates_for(word).min_by { |w| letters_different(w,target) }
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
