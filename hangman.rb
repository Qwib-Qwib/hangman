def display_main_menu
  saves_detected = print_main_menu_instruction
  main_menu_user_input(saves_detected)
end

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
    puts 'New game starting now!'
  elsif saves_detected == true
    check_main_menu_input_with_saves(user_input)
  elsif saves_detected == false
    check_main_menu_input_without_saves(user_input)
  end
end

def check_main_menu_input_with_saves(user_input)
  case user_input
  when '2' then puts "Here's the save list!"
  when '3' then puts 'Quitting game now!'
  else puts 'Incorrect input!'
  end
end

def check_main_menu_input_without_saves(user_input)
  case user_input
  when '2' then puts 'Quitting game now!'
  else puts 'Incorrect input!'
  end
end

display_main_menu