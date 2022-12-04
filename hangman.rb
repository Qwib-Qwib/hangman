# Print the main menu and deals with player interactions inside it.
class MainMenu
  class << self
    def display_main_menu
      saves_detected = print_main_menu_instruction
      main_menu_user_input(saves_detected)
    end

    private

    def print_main_menu_instruction
      puts 'Hey there, player! Fancy a game of Hangman?'
      puts 'Make your choice by choosing the corresponding number and pressing Enter!'
      puts '1. New Game'
      print_with_saves_or_not
    end

    def print_with_saves_or_not
      if Dir.empty?('saves')
        puts '2. Quit'
        false
      else
        puts '2. Load Game'
        puts '3. Quit'
        true
      end
    end

    def main_menu_user_input(saves_detected)
      user_input = gets.chomp
      check_main_menu_user_input(user_input, saves_detected)
    end

    def check_main_menu_user_input(user_input, saves_detected)
      if user_input == '1'
        current_game = GameInstance.new
        current_game.start_game
      elsif saves_detected == true
        check_main_menu_input_with_saves(user_input)
      elsif saves_detected == false
        check_main_menu_input_without_saves(user_input, saves_detected)
      end
    end

    def check_main_menu_input_with_saves(user_input, saves_detected)
      case user_input
      when '2' then puts "Here's the save list!"
      when '3' then puts 'Quitting game now!'
      else
        puts 'Incorrect input!'
        main_menu_user_input(saves_detected)
      end
    end

    def check_main_menu_input_without_saves(user_input, saves_detected)
      case user_input
      when '2' then puts 'Quitting game now!'
      else
        puts 'Incorrect input!'
        main_menu_user_input(saves_detected)
      end
    end
  end
end

# Tasked with drawing the interface for each game, both text and graphics.
module GameInstanceInterface
  def print_game_info(secret_word, correct_guesses, wrong_guesses)
    print_word(secret_word, correct_guesses)
    print_drawing(mistakes_count)
    print_wrong_guesses(wrong_guesses)
  end

  def print_word(secret_word, correct_guesses)
    secret_word.each_char do |char|
      if correct_guesses.include?(char)
        print " #{char} "
      else
        print ' _ '
      end
    end
    puts ''
  end

  def print_wrong_guesses(wrong_guesses)
    puts "Incorrect guesses so far: #{wrong_guesses.join(', ')}"
  end

  def print_drawing(mistakes_count)

  end

  def ask_for_guess
    puts 'Type your guess!'
    guess = gets.chomp
    guess = check_if_guess_letter(guess)
    check_if_guess_already_given(guess)
  end

  def check_if_guess_letter(guess)
    while guess.length != 1 || guess.codepoints[0] < 97 || guess.codepoints[0] > 122
      puts 'Incorrect input! Your guess must be a letter.'
      guess = gets.chomp
    end
    guess
  end

  def check_if_guess_already_given(guess)
    if correct_guesses.include?(guess) || wrong_guesses.include?(guess)
      puts 'You already gave that one. ;)'
      guess = gets.chomp
    end
    guess
  end
end

# An instance of a new game, each keeping all relevant infos about their assigned game.
class GameInstance
  include GameInstanceInterface
  @game_instances = 0

  class << self
    attr_accessor :game_instances
  end

  def initialize
    self.class.game_instances += 1
    @mistakes_count = 0
    @game_name = "game_#{self.class.game_instances}" # This will allow us to keep several numbered saves.
    @secret_word = pick_secret_word
    @correct_guesses = []
    @wrong_guesses = []
  end

  attr_reader :secret_word
  attr_accessor :mistakes_count, :correct_guesses, :wrong_guesses

  def start_game
    while mistakes_count < 12 && (secret_word.split('').uniq - correct_guesses).empty? == false
      print_game_info(secret_word, correct_guesses, wrong_guesses)
      play_turn
    end
  end

  private

  def pick_secret_word
    dictionary = File.open('google-10000-english-no-swears.txt')
    valid_words = dictionary.readlines.map(&:chomp).delete_if { |word| word.length < 5 || word.length > 12 }
    valid_words.sample
  end

  def play_turn
    guess = ask_for_guess
    process_guess(guess)
  end

  def process_guess(guess)
    if guess_right?(guess) == true
      puts 'Good job!'
      correct_guesses.push(guess)
    else
      puts 'What a shame...'
      self.mistakes_count += 1
      wrong_guesses.push(guess)
    end
  end

  def guess_right?(guess)
    secret_word.include?(guess)
  end
end

MainMenu.display_main_menu
