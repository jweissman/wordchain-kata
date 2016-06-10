require 'forwardable'
require 'wordchain/version'

module Wordchain
  class Dictionary
    extend Forwardable
    def_delegators :entries, :size, :include?, :empty?

    def entries
      @entries ||= Dictionary.entries_from_system
    end

    def self.entries_from_system
      File.
        readlines('/usr/share/dict/words').
        map(&:chomp)
    end
  end

  class Chain
    def initialize(start_with:, end_with:, dictionary:)
      @dictionary = dictionary
      @start_with = start_with
      @end_with = end_with
    end

    def construct
      current_word = @start_with
      final_word = @end_with
      chain = []

      until current_word == final_word
        chain << current_word
        current_word = candidates_for(current_word).min_by { |w| letters_different(w, final_word) }
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

    # def edit_distance_between(word_a, word_b)
    # end


    # def candidates_for(word)
    #   # 1-edit distance away!
    # end

    # def edit_distance_between(word_a, word_b)
    # end
  end
end
