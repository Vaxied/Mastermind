module Mastermind
  # Class for playing with a computer instead of 2 players
  class Computer

    attr_accessor :indexed_secret_combination, :computer_guess, :list_of_combinations,
                  :indexed_colors

    def initialize
      @initial_guess = []
      @computer_guess = []
      @list_of_combinations = []
      @available_colors = %w[Red Green Blue Yellow Pink Fucsia]
      @indexed_colors = []
      @indexed_secret_combination = []
      @first_guess = false
    end

    def index_colors
      @available_colors.each_index do |index| 
        @indexed_colors.push(index)
      end
      @indexed_colors
    end

    def transform_to_colors(code, guess = [])
      code.each do |index|
        guess.push(@available_colors[index].downcase)
      end
      guess
    end

    def build_list
      @list_of_combinations = @indexed_colors.repeated_permutation(4).to_a
      @list_of_combinations
    end

    def select_random_code
      options = @available_colors.shuffle
      2.times { options.pop }
      options.map(&:downcase)
    end

    def choose_guess
      # p @list_of_combinations
      # Fix tomorrow, make it give a code ready so you
      # dont need to transform it
      # and give downcase it
      if @first_guess == false
        @first_guess = true
        return [0,0,1,1] 
      end
      @list_of_combinations.sample
    end

    def reset_computer
      self.computer_guess = []
      self.list_of_combinations = []
      self.indexed_secret_combination = []
      @first_guess = false
    end
  end
end