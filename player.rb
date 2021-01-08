# require_relative 'game'

module Mastermind
# class for player(s)
  class Player
    attr_accessor :name, :points
    # Variable for managing the state of the computer
    @comp = nil

    class << self
      attr_accessor :comp
    end

    def initialize(input)
      @name = input[:name]
      @points = 0
    end

    def self.ask_player
      puts 'Welcome to Mastermind'
      puts 'Do you want to play against a partner? (y/n)'
      answer = gets.chomp
      positive_answers = %w[y Y]
      negative_answers = %w[n N]
      if positive_answers.include?(answer)
        @comp = nil
        puts "Please enter the name of the first player:\n\n"
        codemaker = Mastermind::Player.new({ name: gets.chomp })
        puts "Please enter the name of the second player:\n\n"
        codebreaker = Mastermind::Player.new({ name: gets.chomp })
        players = [codemaker, codebreaker]
        Mastermind::Game.new(players).play
      elsif negative_answers.include?(answer)
        human = nil
        @comp = 1
        loop do
          puts "Please pick your name:\n\n"
          human = Mastermind::Player.new({ name: gets.chomp })
          break unless human.name == 'Computer'
        end
        puts ''
        machine = Mastermind::Player.new({ name: 'Computer' })
        players = [machine, human]
        Mastermind::Game.new(players).play
      end
    end
  end
end