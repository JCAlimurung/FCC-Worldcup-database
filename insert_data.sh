#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Clear existing data
echo "$($PSQL "TRUNCATE TABLE games, teams RESTART IDENTITY")"

# Read games.csv file and insert data (skip first line)
cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Skip the header
  if [[ $YEAR != "year" ]]
  then
    # Insert unique teams
    for TEAM in "$WINNER" "$OPPONENT"
    do
      TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$TEAM'")
      if [[ -z $TEAM_ID ]]
      then
        echo "$($PSQL "INSERT INTO teams(name) VALUES('$TEAM')")"
      fi
    done

    # Get team IDs
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # Insert game data
    echo "$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) 
    VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")"
  fi
done
