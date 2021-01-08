module Mastermind

  # class for the board
  class Board
    attr_accessor :grid, :game, :scores
    def initialize(game, input = {})
      @game = game
      @grid = input.fetch(:grid, default_grid)
      @scores = []
    end

    def formatted_grid
      index = 0
      row_number = 0
      grid.each do |row|
        puts row.map { |cell| cell.empty? ? '_' : cell }.join(' ')
        # To make the scores appear below each row
        score = game.count_beads(game.guess_to_compare)
        # p "scores length is #{scores.length}"
        # p "row number is #{row_number}"
        if scores.empty?
          scores.push(score)
          p scores[index]
          index += 1
        elsif row != ['', '', '', ''] && row_number == scores.length
          scores.push(score)
          p scores[index]
          index += 1
        elsif row != ['', '', '', '']
          p scores[index]
          index += 1
        end
        row_number += 1
      end
      p scores
    end

    def reset_board
      self.grid = default_grid
      self.scores = []
    end

    def mastermind_winner?
      # puts 'here comes the flatten'
      grid.flatten.none_empty?
    end

    def get_row(row)
      grid[row]
    end

    def set_row(row, value)
      # TODO
      grid[row] = value
      # p @turns
      # @turns += 1
    end

    private

    def default_grid
      Array.new(12) { ['', '', '', ''] }
    end
  end
end