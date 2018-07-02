require 'sinatra'
require 'sinatra/reloader'

get "/game" do
  letter = params['letter']
  start = PlayerInterface.start_new_game
  erb :index, class: Hangman, class: PlayerInterface
  # hint = Hangman.change_hint
end

class Hangman
  attr_reader :word, :hint, :correct, :incorrect

  def initialize(file, shortest_word=5, longest_word=12)
    @dictionary = read_dictionary(file, shortest_word, longest_word)
    @word = choose_word.strip.downcase
    @hint = ''.rjust(@word.length, '-')
    @correct = []
    @incorrect = []
  end

# Select a word
  def read_dictionary(file, shortest_word, longest_word)
    random_word = nil
    File.readlines(file).select { |word| word.strip.length.between?(shortest_word-1, longest_word)}
  end

  def choose_word
    word = @dictionary[rand(0..@dictionary.length)]
    @dictionary = ''
    word
  end

# Guesses
  def game_over?
    @hint == @word
  end

  def guess(letter)
    if @word.split('').include? letter
      @correct << letter
    else
      @incorrect << letter
    end
    change_hint
  end

  def change_hint
    @word.split('').each_with_index do |letter, i|
      @hint[i] = letter if @correct.include? letter
    end
  end
end

class PlayerInterface

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
