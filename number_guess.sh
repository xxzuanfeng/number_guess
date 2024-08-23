#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
echo "Enter your username:"
read USERNAME
GAMES_PLAYED=$($PSQL "SELECT games_played FROM guessing_game WHERE username='$USERNAME';")
BEST_GAME=$($PSQL "SELECT best_game FROM guessing_game WHERE username='$USERNAME';")

RESULT_USERNAME=$($PSQL "SELECT COUNT(username) FROM guessing_game WHERE username='$USERNAME'")
if [[ $RESULT_USERNAME -eq 0 ]]
then
  $PSQL "INSERT INTO guessing_game(username) VALUES('$USERNAME');"
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET_NUMBER=$((  $RANDOM % 1000 + 1  ))
echo "Guess the secret number between 1 and 1000:"
read GUESS_NUMBER
NUMBER_OF_GUESSES=0

while [[  $GUESS_NUMBER -ne $SECRET_NUMBER  ]]
do
  if [[ ! $GUESS_NUMBER =~ ^-?[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    read GUESS_NUMBER
  else
      if [[ $GUESS_NUMBER -gt $SECRET_NUMBER ]]
      then
        echo "It's lower than that, guess again:"
        NUMBER_OF_GUESSES=$(( $NUMBER_OF_GUESSES + 1 ))
        read GUESS_NUMBER
      else
        echo "It's higher than that, guess again:"
        NUMBER_OF_GUESSES=$(( $NUMBER_OF_GUESSES + 1 ))
        read GUESS_NUMBER 
    fi
  fi
done
NUMBER_OF_GUESSES=$(( $NUMBER_OF_GUESSES + 1 ))

if [[ -z "$GAMES_PLAYED" ]]
then
  GAMES_PLAYED=1
  RESULT_GAMES_PLAYED1=$($PSQL "UPDATE guessing_game SET games_played=$GAMES_PLAYED WHERE username='$USERNAME';")
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM guessing_game WHERE username='$USERNAME'")
  GAMES_PLAYED=$(( $GAMES_PLAYED + 1 ))
  RESULT_GAMES_PLAYED2=$($PSQL "UPDATE guessing_game SET games_played=$GAMES_PLAYED WHERE username='$USERNAME'")
fi

if [[ -z $BEST_GAME ]]
then
  BEST_GAME=$NUMBER_OF_GUESSES    
  RESULT_BEST_GAME1=$($PSQL "UPDATE guessing_game SET best_game=$NUMBER_OF_GUESSES WHERE username='$USERNAME'")
else
  if  [[ $BEST_GAME -ge $NUMBER_OF_GUESSES ]]
  then
    RESULT_BEST_GAME1=$($PSQL "UPDATE guessing_game SET best_game=$NUMBER_OF_GUESSES WHERE username='$USERNAME'")
  fi
fi
echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"