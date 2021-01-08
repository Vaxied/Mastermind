# require_relative 'player'
# require_relative 'board'
# require_relative 'computer'
# require_relative 'array'

module Mastermind
  # Class for managing the game
  class Game

    CODE_LENGTH = 4

    private

    attr_reader :players, :board, :computer, :available_colors
    attr_accessor :rounds, :games, :mastermind_player, :decoding_player,
                  :secret_combination, :guess

    public

    attr_accessor :guess_to_compare, :guessed_code

    def initialize(players, board = Board.new(self), computer = Computer.new)
      @players = players
      @board = board
      @computer = computer
      @rounds = 0
      @games = 0
      @mastermind_player, @decoding_player = players
      @available_colors = %w[Red Green Blue Yellow Pink Fucsia]
      @secret_combination = []
      @guess = []
      @guess_to_compare = []
    end

    def play
      # p players
      # @computer.index_colors
      # @computer.build_list
      puts "#{mastermind_player.name} is the mastermind"
      puts "#{decoding_player.name} is the decoder"
      # puts "#{Player.comp} is the state of the computer"
      guessed_code = []
      row = 0
      code = false
      # board.formatted_grid
      loop do
        puts ''
        # puts "#{row} is the row"
        if code == false && (Player.comp.nil? || Player.comp == 0)
          loop do
            solicit_secret_combination
            get_secret_combination
            break if validate_secret_combination
          end
        elsif code == false && Player.comp == 1

          self.secret_combination = computer.select_random_code
          puts 'The computer has selected a secret code'
          # p secret_combination
        end
        # board.formatted_grid
        puts ''
        code = true
        if Player.comp.nil? || Player.comp == 1
          loop do
            solicit_guess
            guessed_code = get_guess
            break if validate_guess
          end
        elsif Player.comp == 0
          if computer.indexed_colors.empty?
          computer.index_colors
          end
          if computer.list_of_combinations.empty?
            computer.build_list
          end
          indexed_guessed_code = computer.choose_guess
          guessed_code = computer.transform_to_colors(indexed_guessed_code)
          puts guessed_code.join(' ')
          puts 'computer has guessed a code'
        end
        abreviated_code = convert_first_letters(guessed_code)
        board.set_row(row, abreviated_code)
        self.guess_to_compare = guessed_code
        board.formatted_grid
        puts ''
        give_feedback(guessed_code)
        if Player.comp == 0
          reduce_options(indexed_guessed_code)
          # puts 'Remaining list'
          # p computer.list_of_combinations
          sleep 3
        end
        row += 1
        # puts 'is round over?'
        next unless round_over(guessed_code)

        if game_over
          puts game_over_message
          break
        end
        puts 'Round is over, resetting board'
        row = 0
        code = false
        switch_roles
        board.reset_board
        reset_codes_and_computer
        # Switch computer role
        if Player.comp == 1
          Player.comp = 0
        elsif Player.comp == 0
          Player.comp = 1
        end
      end
    end

    def switch_roles
      @mastermind_player, @decoding_player = @decoding_player, @mastermind_player
      puts "#{mastermind_player.name} is now the mastermind"
      puts "#{decoding_player.name} is now the decoding player"
      puts ''
    end

    def solicit_guess
      puts "#{decoding_player.name}: Choose a possible 4 color combination from"
      puts available_colors.map { |color| color }.join(' ')
      puts ''
    end

    def get_guess(code = gets.chomp.downcase)
      self.guess = code.split
    end

    def validate_guess
      return true if check_words(guess) && guess.length == CODE_LENGTH

      puts 'Code is invalid, please enter a valid code'
      false
    end

    def validate_secret_combination
      if check_words(secret_combination) && secret_combination.length == CODE_LENGTH
        puts "Secret combination is valid and has been saved\n"
        true
      else
        puts "Code is invalid, please enter a valid code\n"
        false
      end
    end

    def check_words(code)
      puts 'checking words'
      code.each do |word|
        return false unless available_colors.include?(word.capitalize)
      end
    end

    def solicit_secret_combination
      puts "#{mastermind_player.name}: Select a secret four color code from the available colors" 
      puts available_colors.map { |color| color }.join(' ')
      puts ''
    end

    def get_secret_combination(combination = gets.chomp.downcase)
      self.secret_combination = combination.split
    end

    def indexed_combination
      @secret_combination.each do |color|
        index = @available_colors.find_index(color.capitalize)
        computer.indexed_secret_combination.push(index)
      end
      computer.indexed_secret_combination
    end

    def convert_first_letters(code)
      code.map { |word| word[0].capitalize }
    end

    def round_over(code)
      # puts 'entering round over'
      puts 'checking if the code matches'
      beads = count_beads(code)
      if beads[0] == CODE_LENGTH
        self.rounds += 1
        increase_games
        puts 'Code was correct'
        if beads[0] == CODE_LENGTH && @games == 2
          return true
        end
        puts 'Changing roles...'
        # board.reset_board
        # reset_codes_and_computer
        true
      elsif board.mastermind_winner?
        self.rounds += 1
        increase_games
        puts 'Decoder player failed to decipher the code in 12 turns'
        puts "The secret code was #{secret_combination.map(&:capitalize).join(" ")}"
        add_points_to_coder
        # reset_codes_and_computer
        true
      end
    end

    def increase_games
      if rounds == 2
        self.games += 1
        self.rounds = 0
      end
    end

    def add_points_to_coder
      puts "#{mastermind_player.name} earned one point"
      mastermind_player.points += 1
    end

    def give_feedback(code)
      beads = count_beads(code)
      puts "#{beads[0]} right colors exist and are in the right position"
      puts "#{beads[1]} right colors exist but are in the wrong position"
      beads
    end

    # Evualuate the feedback to reduce the amount of possible combinations
    def reduce_options(indexed_guessed_code)
      guessed_code = computer.transform_to_colors(indexed_guessed_code)
      guess_score = count_beads(guessed_code)
      score_sum = guess_score.inject(0, :+)
      computer.list_of_combinations.each_with_index do |code, index|
        colored_code = computer.transform_to_colors(code)
        code_score = count_beads(colored_code)
        new_score_sum = code_score.inject(0, :+)
        # puts "guess score #{guess_score}, code score #{code_score}"
        next if code_score[0] == 4
        if code == indexed_guessed_code
          computer.list_of_combinations.delete_at(index)
        elsif  guess_score != code_score || new_score_sum <= score_sum
          # puts "#{new_score_sum} <= #{score_sum}"
          computer.list_of_combinations.delete_at(index)
        end
      end
      # p computer.list_of_combinations.length
      # p computer.list_of_combinations
    end

    def count_beads(code, black_beads = 0, white_beads = 0)
      black_beaded_colors = Array.new
      white_beaded_colors = Array.new
      # Counts the black beads first
      code.each_with_index do |color, index|
        if secret_combination[index] == color
          black_beaded_colors.push(color)
          black_beads += 1
          return [black_beads, white_beads] if black_beads == CODE_LENGTH
        end
        # max one white bead for each color
        next if white_beaded_colors.include?(color) || black_beaded_colors.include?(color)
        # Fix that is not needed given the current conditions:
        # The maximum amount of colors awarded must be the same that of in the secret code
        # green green green red blue code suggested with pink fucsia yellow green green
        # must print [0, 2] and not [0, 1], hint: can be done with a hashmap.
        if secret_combination.include?(color)
          white_beaded_colors.push(color)
          white_beads += 1
        end
      end
      [black_beads, white_beads]
    end
    #   end
    #   # After counting the black beads, now its time to count the white ones
    #   # code.each do |color|
    #     next if black_beaded_colors.include?(color) || white_beaded_colors.include?(color)
    #     if secret_combination.include?(color)
    #       white_beads += 1
    #       # max one white bead for each color
    #       beaded_colors.push(color)
    #     end
    #   end
    #   [black_beads, white_beads]
    # end

    def reset_codes_and_computer
      self.secret_combination = []
      self.guess = []
      computer.reset_computer
    end

    def game_over
      return true if winner? && games == 2

      return true if draw? && games == 2
      # false
    end

    def game_over_message
      # breaks if computer wins, check it out!
      return "The game ended in a tie\nThanks for playing" if draw?

      if winner?
        return "#{determine_winner.name} has won with #{determine_winner.points} points\nThanks for playing"
      end
    end

    def determine_winner
      return mastermind_player if mastermind_player.points > decoding_player.points
      # else
      return decoding_player
    end

    def winner?
      return true if mastermind_player.points != decoding_player.points

      false
    end

    def draw?
      return true if mastermind_player.points == decoding_player.points

      false
    end
  end
end
