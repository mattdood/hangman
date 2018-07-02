require 'sinatra'
require 'sinatra/reloader'

class PlayerInterface
  require_relative 'game'

  def initialize
    display_greeting
    @hangman = ''
  end

  def display_greeting
    puts "Welcome, please enter a number to select an option"
    puts "1 => New Game"
    puts "2 => Load Game"
    puts "3 => Quit"
    react_to_greeting(get_input(/[1|2|3]/))
  end

  def get_input(expected_result)
    result = 0
    count = 0
    until result =~ expected_result do
      puts "Enter a valid number" if count > 0
      result = gets.chomp.downcase
      count += 1
        if result == 'quit'
          exit
        end
    end
      result
  end

  def start_new_game
    puts "Starting new"
    @hangman = Hangman.new('5desk.txt')
    game_loop
  end

  def game_loop
    puts @hangman.word
    turns = 10
    until turns == 0 do
      puts "Hint: #{@hangman.hint} | Incorrect Letters: #{@hangman.incorrect.join(',')} | Turns Left: #{turns}"
      victory?

      unguessed_chars = array_to_regex(('a'..'z').to_a - (@hangman.correct + @hangman.incorrect))
      guess = ''
      until guess.length == 1
      	guess = get_input(unguessed_chars)
      end

      @hangman.make_guess(guess)
      turns -= 1
    end
    victory?
    puts hangman.hint
    puts "You lost! The word was #{hangman.word}"
  end

  def array_to_regex(array)
  	regex = array.join('|')
  	/#{regex}/
  end

  def victory?
  	if @hangman.game_over?
      	puts "You win!"
 		exit
    end
  end

end

PlayerInterface.new
