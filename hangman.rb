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

# Tasked with saving and drawing the hangman figure for each game.
class Drawing
  def initialize
    @a = [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ']
    @b = [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ']
    @c = [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ']
    @d = [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ']
    @e = [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ']
    @f = [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ']
    @g = [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ']
  end

  attr_reader :a, :b, :c, :d, :e, :f, :g

  def print_drawing
    print_row(a)
    print_row(b)
    print_row(c)
    print_row(d)
    print_row(e)
    print_row(f)
    print_row(g)
  end

  def edit_drawing(mistakes_count)
    case mistakes_count
    when 1 then edit_hangman_for_one_mistake
    when 2 then edit_hangman_for_two_mistakes
    when 3 then edit_hangman_for_three_mistakes
    when 4 then edit_hangman_for_four_mistakes
    when 5 then edit_hangman_for_five_mistakes
    when 6 then edit_hangman_for_six_mistakes
    when 7 then edit_hangman_for_seven_mistakes
    when 8 then edit_hangman_for_eight_mistakes
    when 9 then edit_hangman_for_nine_mistakes
    when 10 then edit_hangman_for_ten_mistakes
    when 11 then edit_hangman_for_eleven_mistakes
    when 12 then edit_hangman_for_twelve_mistakes
    end
  end

  private

  def print_row(row)
    row.each { |tile| print tile }
    puts ''
  end

  def edit_hangman_for_one_mistake
    b[0] = c[0] = d[0] = e[0] = f[0] = g[0] = '|'
  end

  def edit_hangman_for_two_mistakes
    g[10] = '|'
  end

  def edit_hangman_for_three_mistakes
    f[1] = f[2] = f[3] = f[4] = f[5] = f[6] = f[7] = f[8] = f[9] = f[10] = '_'
  end

  def edit_hangman_for_four_mistakes
    a[0] = a[1] = a[2] = a[3] = a[4] = a[5] = a[6] = a[7] = a[8] = a[9] = '_'
  end

  def edit_hangman_for_five_mistakes
    b[1] = '/'
  end

  def edit_hangman_for_six_mistakes
    b[9] = '|'
  end

  def edit_hangman_for_seven_mistakes
    c[9] = 'O'
  end

  def edit_hangman_for_eight_mistakes
    d[9] = '|'
  end

  def edit_hangman_for_nine_mistakes
    d[8] = '\\'
  end

  def edit_hangman_for_ten_mistakes
    d[10] = '/'
  end

  def edit_hangman_for_eleven_mistakes
    e[8] = '/'
  end

  def edit_hangman_for_twelve_mistakes
    e[10] = '\\'
  end
end

# Tasked with drawing the interface for each game.
module GameInstanceInterface
  def print_game_info(secret_word, correct_guesses, wrong_guesses, drawing)
    print_word(secret_word, correct_guesses)
    drawing.print_drawing
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

  def ask_for_guess
    puts 'Type your guess!'
    guess = gets.downcase.chomp
    guess = check_if_guess_letter(guess)
    check_if_guess_already_given(guess)
  end

  def check_if_guess_letter(guess)
    while guess.length != 1 || guess.codepoints[0] < 97 || guess.codepoints[0] > 122
      puts 'Incorrect input! Your guess must be a letter.'
      guess = gets.downcase.chomp
    end
    guess
  end

  def check_if_guess_already_given(guess)
    if correct_guesses.include?(guess) || wrong_guesses.include?(guess)
      puts 'You already gave that one. ;)'
      guess = gets.downcase.chomp
    end
    guess
  end
end

# An instance of a new game, each keeping all relevant infos about their assigned game.
class GameInstance
  include GameInstanceInterface
  require 'io/console'
  require 'io/wait' # Required for the ready? method.
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
    @drawing = Drawing.new
  end

  attr_reader :secret_word
  attr_accessor :mistakes_count, :correct_guesses, :wrong_guesses, :drawing

  def start_game
    while mistakes_count < 12 && (secret_word.split('').uniq - correct_guesses).empty? == false
      print_game_info(secret_word, correct_guesses, wrong_guesses, drawing)
      play_turn
    end
    drawing.print_drawing if mistakes_count == 12
    print_end_message(mistakes_count)
    MainMenu.display_main_menu
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

  def print_end_message(mistakes_count)
    case mistakes_count
    when 12 then puts 'FAILURE'
    else puts 'WOAH, INCREDIBLE!'
    end
    puts 'Press any key to continue.'
    $stdin.getch
    $stdin.getch while $stdin.ready? == true # Used to clear the buffer of any "parasite" input for keys generating multiple values.
  end

  def process_guess(guess)
    if guess_right?(guess) == true
      puts 'Good job!'
      correct_guesses.push(guess)
    else
      puts 'What a shame...'
      self.mistakes_count += 1
      wrong_guesses.push(guess)
      drawing.edit_drawing(mistakes_count)
    end
  end

  def guess_right?(guess)
    secret_word.include?(guess)
  end
end

MainMenu.display_main_menu
