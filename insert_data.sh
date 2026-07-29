#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Exit code
	ERROR_MESSAGE() {
		echo -e "\nError. Please double check the code.\n"
	}

# TRUNCATE TABLE
	EMPTY_TABLES=$($PSQL "TRUNCATE TABLE games, teams")
	if [[ $EMPTY_TABLES == "TRUNCATE TABLE" ]]
	then
		echo -e "\nSuccessfully truncated tables.\n"
	else
		ERROR_MESSAGE
	fi
	
# read games.csv into bash variables
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
# fills the tables
do
	# skipping header row
	if [[ $YEAR != year ]]
	then
		# Building teams table
		# check if team exists - winner col case
		TEAM_ID_WINNER=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
		# if team doesn't exist
		if [[ -z $TEAM_ID_WINNER ]]
		then
			INSERT_NEW_TEAM_WINNER=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
			# if insertion succeeds
			if [[ $INSERT_NEW_TEAM_WINNER == "INSERT 0 1" ]]
			then
				echo -e "\nInserted $WINNER team into teams table.\n"
			else
				ERROR_MESSAGE
			fi
		fi
		# check if team exists - opponent col case
		TEAM_ID_OPPONENT=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
		# if team doesn't exist
		if [[ -z $TEAM_ID_OPPONENT ]]
		then
			INSERT_NEW_TEAM_OPPONENT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
			# if insertion succeeds
			if [[ $INSERT_NEW_TEAM_OPPONENT == "INSERT 0 1" ]]
			then
				echo -e "\nInserted $OPPONENT team into teams table.\n"
			else
				ERROR_MESSAGE
			fi
		fi
		
		# Building games table
		# Get winner_id and opponent_id
		WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
		OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
		# check if a game exists
		GAME_ID=$($PSQL "SELECT game_id FROM games WHERE year = $YEAR AND winner_id = $WINNER_ID AND opponent_id = $OPPONENT_ID")
		# if game not yet exists
		if [[ -z $GAME_ID ]]
		then
			INSERT_NEW_GAME=$($PSQL "INSERT INTO games(year, round, winner_id, winner_goals, opponent_id, opponent_goals) VALUES ($YEAR, '$ROUND', $WINNER_ID, $WINNER_GOALS, $OPPONENT_ID, $OPPONENT_GOALS)")
			# if insertion succeeds
			if [[ $INSERT_NEW_GAME == "INSERT 0 1" ]]
			then
				echo -e "\nInserted $YEAR-$WINNER-$OPPONENT game into games table.\n"
			# if insertion fails
			else
				ERROR_MESSAGE
			fi	
		fi
	fi
done	