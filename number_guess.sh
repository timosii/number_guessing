#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read NAME

USERNAME=$($PSQL "SELECT username FROM users WHERE username = '$NAME'")

if [[ -z $USERNAME ]]
then
  echo "Welcome, $NAME! It looks like this is your first time here."
  GAMES_COUNT=0
  ADD_USER=$($PSQL "INSERT INTO users(username, games_count) VALUES('$NAME', $GAMES_COUNT)")
else
  GAMES_COUNT=$($PSQL "SELECT games_count FROM users WHERE username = '$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME'")
  echo "Welcome back, $USERNAME! You have played $GAMES_COUNT games, and your best game took $BEST_GAME guesses."
fi

NUMBER_GUESSING=$(( RANDOM % 1000 + 1 ))
TRY_COUNT=0
echo "Guess the secret number between 1 and 1000:"
GUESSING() {
read NUMBER
if [[ ! $NUMBER =~ ^[0-9]+$ ]]
then
  echo "That is not an integer, guess again:"
  GUESSING
else
  if [[ $NUMBER -gt $NUMBER_GUESSING ]]
  then
    (( TRY_COUNT++ ))
    echo "It's lower than that, guess again:"
    GUESSING
  elif [[ $NUMBER -lt $NUMBER_GUESSING ]]
  then
    (( TRY_COUNT++ ))
    echo "It's higher than that, guess again:"
    GUESSING
  else
    (( TRY_COUNT++ ))
    echo "You guessed it in $TRY_COUNT tries. The secret number was $NUMBER_GUESSING. Nice job!"
  fi
fi
}
GUESSING
UPDATE_GAMES_COUNT=$($PSQL "UPDATE users SET games_count=games_count + 1 WHERE username = '$NAME'")

if [[ ! $BEST_GAME ]]
then
  BEST_GAME=$TRY_COUNT
  UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game=$BEST_GAME WHERE username = '$NAME'")
fi

if [[ $BEST_GAME ]]
then
  if [[ $TRY_COUNT -lt $BEST_GAME ]]
  then
    BEST_GAME=$TRY_COUNT
    UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game=$BEST_GAME WHERE username = '$NAME'")
  fi
fi
