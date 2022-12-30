# frozen_string_literal: false

# Contains methods usable by interfaces across the whole game.
module GeneralInterface
  require 'io/wait' # Required for the ready? method.
  require 'io/console' # Required for the getch method.

  def press_any_key_to_continue
    $stdin.getch
    $stdin.getch while $stdin.ready? == true # Used to clear the buffer of any "parasite" input for keys generating multiple values.
  end

  def clear_screen
    system('clear')
  end
end

# Methods related to the save management menu accessible from the Main menu.
module SaveManagementMenu
  class << self
    include GeneralInterface
    def open_savefile_menu
      clear_screen
      Dir.children('saves').each { |savefile| puts savefile }
      puts "\nType 'load', 'erase' or 'quit' if you want to load a file, erase a file or return to the main menu."
      menu_option = gets.chomp.downcase
      evaluate_savefile_menu_option(menu_option)
    end

    def evaluate_savefile_menu_option(menu_option)
      if %w[load erase quit].include?(menu_option)
        case menu_option
        when 'load' then open_load_menu
        when 'erase' then open_erase_menu
        when 'quit' then MainMenu.display_main_menu
        end
      else
        reject_illegal_savefile_menu_options
      end
    end

    def reject_illegal_savefile_menu_options
      puts "Please type a valid option ('erase', 'load', 'quit')."
      menu_option = gets.chomp.downcase
      evaluate_savefile_menu_option(menu_option)
    end

    def open_load_menu
      clear_screen
      Dir.children('saves').each { |savefile| puts savefile }
      puts "\nType the name of the save file you'd like to load, or 'quit' to return to the previous menu."
      save_file = gets.chomp.downcase
      evaluate_load_menu_input(save_file)
    end

    def evaluate_load_menu_input(save_file)
      success_flag = 0 # Used to repeat the loop until the desired input is obtained.
      success_flag = load_menu_input_evaluation_loop(save_file) until success_flag == 1
    end

    def load_savefile(save_file)
      loaded_game = YAML.safe_load_file("saves/#{save_file}", permitted_classes: [GameInstance, Drawing])
      loaded_game.start_game
      1
    end

    def load_menu_input_evaluation_loop(save_file)
      if ["\"", "\'", '/', "\`"].any? { |char| save_file.include?(char) } || save_file == ''
        save_file = forbid_special_characters_and_names('load')
      elsif save_file == 'quit'
        open_savefile_menu
        1
      elsif File.exist?("saves/#{save_file}") == false
        save_file = reject_nonexistent_savefile('load')
      else
        load_savefile(save_file)
      end
    end

    def open_erase_menu
      clear_screen
      Dir.children('saves').each { |savefile| puts savefile }
      puts "\nType the name of the save file you'd like to erase, or 'quit' to return to the previous menu"
      save_file = gets.chomp.downcase
      evaluate_erase_menu_input(save_file)
    end

    def evaluate_erase_menu_input(save_file)
      success_flag = 0
      success_flag = erase_menu_input_evaluation_loop(save_file) until success_flag == 1
    end

    def forbid_special_characters_and_names(menu_option)
      puts "Invalid filename!\nForbidden characters: \" \' \` /\nEmpty file names are also forbidden."
      case menu_option
      when 'load' then load_menu_input_evaluation_loop(gets.chomp.downcase)
      when 'erase' then erase_menu_input_evaluation_loop(gets.chomp.downcase)
      end
    end

    def reject_nonexistent_savefile(menu_option)
      puts 'No such save file!'
      case menu_option
      when 'load' then load_menu_input_evaluation_loop(gets.chomp.downcase)
      when 'erase' then erase_menu_input_evaluation_loop(gets.chomp.downcase)
      end
    end

    def erase_savefile(save_file)
      File.delete("saves/#{save_file}")
      puts "File erased!\nPress any key to continue."
      press_any_key_to_continue
      open_erase_menu
      1
    end

    def erase_menu_input_evaluation_loop(save_file)
      if ["\"", "\'", '/', "\`"].any? { |char| save_file.include?(char) } || save_file == ''
        save_file = forbid_special_characters_and_names('erase')
      elsif save_file == 'quit'
        open_savefile_menu
        1
      elsif File.exist?("saves/#{save_file}") == false
        save_file = reject_nonexistent_savefile('erase')
      else
        erase_savefile(save_file)
      end
    end
  end
end

# Print the main menu and deals with player interactions inside it.
class MainMenu
  include GeneralInterface
  include SaveManagementMenu
  class << self
    include GeneralInterface
    def display_main_menu
      clear_screen
      saves_detected = print_main_menu_instruction
      main_menu_user_input(saves_detected)
    end

    private

    def print_main_menu_instruction
      puts 'Hey there, player! Fancy a game of Hangman?'
      puts 'Make your choice by choosing the corresponding number and pressing Enter!'
      puts 'Whenever the game lets you type a keyword option, type them without quotation marks.'
      puts '1. New Game'
      print_with_saves_or_not
    end

    def print_with_saves_or_not
      if Dir.empty?('saves')
        puts '2. Quit'
        false
      else
        puts "2. Load Game\n3. Quit"
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
        check_main_menu_input_with_saves(user_input, saves_detected)
      elsif saves_detected == false
        check_main_menu_input_without_saves(user_input, saves_detected)
      end
    end

    def check_main_menu_input_with_saves(user_input, saves_detected)
      case user_input
      when '2' then SaveManagementMenu.open_savefile_menu
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

# Tasked with drawing the main interface for each game turn.
module GameTurnInterface
  def print_game_info(secret_word, correct_guesses, wrong_guesses, drawing, latest_result_message)
    print_word(secret_word, correct_guesses)
    drawing.print_drawing
    puts latest_result_message if latest_result_message != ''
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
    puts "Type your guess, 'save' if you want to save, or 'quit' to return to the main menu."
    guess = gets.downcase.chomp
    check_input_validity(guess)
  end

  def check_input_validity(guess)
    case guess.downcase
    when 'quit' then 'quit'
    when 'save'
      save_game
      'save'
    else
      guess = check_if_guess_letter(guess)
      check_if_guess_already_given(guess)
    end
  end

  def check_if_guess_letter(guess)
    while guess.length != 1 || guess.codepoints[0] < 97 || guess.codepoints[0] > 122
      puts 'Incorrect input! Your guess must be a letter.'
      guess = gets.downcase.chomp
    end
    guess
  end

  def check_if_guess_already_given(guess)
    while correct_guesses.include?(guess) || wrong_guesses.include?(guess)
      puts 'You already gave that one. ;)'
      guess = gets.downcase.chomp
    end
    guess
  end

  def print_end_screen
    drawing.print_drawing if mistakes_count == 12
    print_end_message(mistakes_count)
  end

  def print_end_message(mistakes_count)
    case mistakes_count
    when 12 then puts 'FAILURE'
    else puts 'WOAH, INCREDIBLE!'
    end
    puts 'Press any key to continue.'
    press_any_key_to_continue
  end
end

# An instance of a new game, each keeping all relevant infos about their assigned game.
class GameInstance
  include GeneralInterface
  include GameTurnInterface
  require 'yaml'
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
    @latest_result_message = ''
  end

  attr_reader :secret_word
  attr_accessor :mistakes_count, :correct_guesses, :wrong_guesses, :drawing, :latest_result_message

  def start_game
    clear_screen
    quit_flag = 0
    # The following loop occurs until player wins, loses or decides to quit.
    while (mistakes_count < 12 && (secret_word.split('').uniq - correct_guesses).empty? == false) && quit_flag != 1
      quit_flag = setup_new_turn
    end
    print_end_screen if quit_flag != 1
    MainMenu.display_main_menu
  end

  def save_game
    puts "Name your save, or type 'quit' to return to the game:"
    save_name = gets.chomp.downcase
    return if save_name == 'quit'

    check_save_name_validity(save_name)
  end

  private

  def pick_secret_word
    dictionary = File.open('google-10000-english-no-swears.txt')
    valid_words = dictionary.readlines.map(&:chomp).delete_if { |word| word.length < 5 || word.length > 12 }
    valid_words.sample
  end

  def setup_new_turn
    print_game_info(secret_word, correct_guesses, wrong_guesses, drawing, latest_result_message)
    quit_flag = play_turn
    clear_screen
    quit_flag
  end

  def play_turn
    guess = ask_for_guess
    case guess
    when 'quit' then 1 # Updates quit_flag, signals player wants to quit.
    when 'save' then play_turn
    else process_guess(guess)
    end
  end

  def process_guess(guess)
    if guess_right?(guess) == true
      @latest_result_message = 'Good job!'
      correct_guesses.push(guess)
    else
      @latest_result_message = 'What a shame...'
      self.mistakes_count += 1
      wrong_guesses.push(guess)
      drawing.edit_drawing(mistakes_count)
    end
  end

  def guess_right?(guess)
    secret_word.include?(guess)
  end

  def check_save_name_validity(save_name)
    if save_name == ''
      puts 'Invalid filename! Your file must have a name.'
      save_game
    elsif ["\"", "\'", '/', "\`"].any? { |char| save_name.include?(char) } || %w[save erase load].any? { |keyword| save_name == keyword }
      puts "Invalid filename!\nForbidden characters: \" \' \` /\nForbidden file names: save, erase, load"
      save_game
    else
      File.open("saves/#{save_name}.yaml", 'w') { |save| YAML.dump(self, save) }
      puts 'Game saved!'
    end
  end
end

MainMenu.display_main_menu
