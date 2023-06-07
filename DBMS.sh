
function mainMenu {
  echo -e "\n+---------Main Menu-------------+"
  echo "| 1. Select DB                  |"
  echo "| 2. Create DB                  |"
  echo "| 3. Rename DB                  |"
  echo "| 4. Drop DB                    |"
  echo "| 5. Show DBs                   |"
  echo "| 6. Exit                       |"
  echo "+-------------------------------+"
  echo -e "Enter Choice: \c"
  read ch
  case $ch in
    1)  selectDB ;;
    2)  createDB ;;
    3)  renameDB ;;
    4)  dropDB ;;
    5)  ls ./DBMS ; mainMenu;;
    6) exit ;;
    *) echo " Wrong Choice " ; mainMenu;
  esac
}


#Selecting Database 
function selectDB { # Enter the Database name the needs to be selected 
  echo -e "Enter Database Name: \c"
  read dbName
  cd ./DBMS/$dbName 2>>./.error.log
  if [[ $? == 0 ]]; then
    echo "Database $dbName was Successfully Selected"
    tablesMenu
  else
    echo "Database $dbName wasn't found"
    mainMenu
  fi
}

#Creating Database
function createDB {
  echo -e "Enter the Database Name: \c"
  read dbName
  mkdir ./DBMS/$dbName  # The mkdir command creates a new directory with the name specified by the user, under the ./DBMS directory. 
  if [[ $? == 0 ]]
  then
    echo "Database is Created"
  else
    echo "Error Creating the Database $dbName"
  fi
  mainMenu
}



#Function 4
# This is a shell Function that renames the Database 
function DatabaseRename { 
  echo -e "Enter the Current Database Name: \c" # The function prompts the user to enter the current database name
  read dbName  # It reads the input using the read Command
  echo -e "Enter the New Database Name: \c" #The function prompts the user to enter the new database name  
  read newName # Reading 
  
  # The mv command is used to rename the directory that represents the current database.
  # The 2>> operator redirects any error messages to the .error.log file.
  mv ./DBMS/$dbName ./DBMS/$newName 2>>./.error.log
  #The function checks the exit status of the mv command using $?. If the exit status is 0,
  #the function prints "Database Renamed Successfully". Otherwise, it prints "Error".
  if [[ $? == 0 ]]; then
    echo "Database is successfully renamed"
  else
    echo "ERROR"
  fi
  mainMenu
}

#Function 5
function dropDB {
  echo -e "Enter Database Name: \c"
  read dbName
  rm -r ./DBMS/$dbName 2>>./.error.log.  #The rm command is used to remove the directory that represents the database.
  # The -r option is used to remove the directory and its contents recursively.

  if [[ $? == 0 ]]; then
    echo "Database Dropped Successfully"
  else
    echo "Database Not found"
  fi
  mainMenu
}

#Function 6
#It calls the tablesMenu function. The menu has nine options, numbered from 1 to 9.
function tablesMenu {
  echo -e "\n+--------Tables Menu------------+"
  echo "| 1. Show Existing Tables       |" #displays a list of existing tables in the current directory
  echo "| 2. Create New Table           |"
  echo "| 3. Insert Into Table          |"
  echo "| 4. Select From Table          |"
  echo "| 5. Update Table               |"
  echo "| 6. Delete From Table          |"
  echo "| 7. Drop Table                 |"
  echo "| 8. Back To Main Menu          |"
  echo "| 9. Exit                       |"
  echo "+-------------------------------+"
  echo -e "Enter Choice: \c"
  read ch
  case $ch in
    1)  ls .; tablesMenu ;;
    2)  createTable ;;
    3)  insert;;
    4)  clear; selectMenu ;;
    5)  updateTable;;
    6)  deleteFromTable;;
    7)  dropTable;;
    8) clear; cd ../.. 2>>./.error.log; mainMenu ;;
    9) exit ;;
    *) echo " Wrong Choice " ; tablesMenu;
  esac

}

#Function 7
#Creating table in the database
function createTable {
  echo -e "Table Name: \c"
  read tableName  #scan table name from the user
  if [[ -f $tableName ]]; then  #checking if the the table name entered already exists
    echo "table already existed ,choose another name"
    tablesMenu  #calling tablesMenu funtion
  fi
  echo -e "Number of Columns: \c"
  read colsNum 
  counter=1  
  sep="|"  # separating columns
  rSep="\n"  # separating rows
  pKey=""    # primary key
  metaData="Field"$sep"Type"$sep"key"  # column name, data type, key type(primary, foreign key) are stored in metadata
  while [ $counter -le $colsNum ]   #counter:tarcking column number
  do
    echo -e "Name of Column No.$counter: \c"
    read colName  #scaning the name of the current column

    echo -e "Type of Column $colName: "
    select var in "int" "str"  #the user has to choose the column type
    do
      case $var in                     #case statement is used to set the colType variable based on the user's selection.                  
        int ) colType="int";break;;    
        str ) colType="str";break;;
        * ) echo "Wrong Choice" ;;     #If the user enters an invalid choice, the script displays a message indicating that the choice was wrong.
      esac
    done
    
    #prompts the user to set a primary key for the current table being created
    if [[ $pKey == "" ]]; then       #checks if a primary key has already been set for the table by checking if $pKey is an empty string 
      echo -e "Make PrimaryKey ? "    # If $pKey is empty, the script asks the user if they want to make the current column the primary key.
      select var in "yes" "no"
      do
        case $var in
          yes ) pKey="PK";   #If the user selects "yes", the script sets the $pKey variable to "PK" and adds metadata for the current column with the primary key flag to the metaData variable.
          metaData+=$rSep$colName$sep$colType$sep$pKey;
          break;;
          no )  #If the user selects "no", the metadata for the current column is added without a primary key flag
          metaData+=$rSep$colName$sep$colType$sep""
          break;;
          * ) echo "Wrong Choice" ;;  #if the user enters an invalid choice the script displays a message that the choice was wrong and prompts the user to select a valid option.
        esac
      done
    else
      metaData+=$rSep$colName$sep$colType$sep""
    fi
    if [[ $counter == $colsNum ]]; then  #checks if the current column is the last column
      temp=$temp$colName
    else
      temp=$temp$colName$sep
    fi
    ((counter++))
  done
  touch .$tableName
  echo -e $metaData  >> .$tableName
  touch $tableName
  echo -e $temp >> $tableName
  if [[ $? == 0 ]]
  then
    echo "Table Created Successfully"
    tablesMenu
  else
    echo "Error Creating Table $tableName"
    tablesMenu
  fi
}

function dropTable {
  echo -e "Enter Table Name: \c"
  read tName
  rm $tName .$tName 2>>./.error.log
  if [[ $? == 0 ]]
  then
    echo "Table Dropped Successfully"
  else
    echo "Error Dropping Table $tName"
  fi
  tablesMenu
}

function insert {
  #-e option enables the interpretation of backslash escape sequences
  #/c so that we input on the same line
  echo -e "Table Name: \c"
  read tableName
  #checks if table name is present
  #-f is a file test operator
  if ! [[ -f $tableName ]]; then
    echo "Table $tableName isn't existed ,choose another Table"
    tablesMenu
  fi
  #this gets the number of rows available in the metadata file of the table
  #the metadata file stores fields name and information of the table
  #we stored the last NR
  colsNum=`awk 'END{print NR}' .$tableName`
  sep="|"
  rowSep="\n"
  #loops on every column we have in the table
  #we skipped the 1st row cuz it contains the headers
  for (( i = 2; i <= $colsNum; i++ )); do
    #this retrieves the first field found which is the column name 
    columnName=$(awk 'BEGIN{FS="|"}{ if(NR=='$i') print $1}' .$tableName)
    #this retrieves the 2nd field found which is the column tyoe 
    columnType=$( awk 'BEGIN{FS="|"}{if(NR=='$i') print $2}' .$tableName)
    #this retrieves the 3rd which is whether this column is a prim key or not
    colKey=$( awk 'BEGIN{FS="|"}{if(NR=='$i') print $3}' .$tableName)
    echo -e "$columnName ($columnType) = \c"
    read input
    
    # if the column type is integer, we have to make the sure the input is all integer
    #this is done by using regex
    if [[ $columnType == "int" ]]; then
      while ! [[ $input =~ ^[0-9]*$ ]]; do
        echo -e "invalid DataType !!"
        echo -e "$columnName ($columnType) = \c"
        read input
      done
    fi
  
    #if the column is a primary key, we have to make sure there is no prim key with the same value
    if [[ $colKey == "PK" ]]; then
      while [[ true ]]; do
        #skips the first row which contains the table fields names
        #outputs the field's values $(('$i' -1))
        #the out record separator is a space
        if [[ $input =~ ^[`awk 'BEGIN{FS="|" ; ORS=" "}{if(NR != 1)print $(('$i'-1))}' $tableName`]$ ]]; then
          echo -e "invalid input for Primary Key !!"
        else
          break;
        fi
        echo -e "$columnName ($columnType) = \c"
        read input
      done
    fi

    #if i reached the final column
    if [[ $i == $colsNum ]]; then
    #we set the row to be = the value of fields we took before
    # plus the value of input we took now
    # + the row separator as we finished input (we reached final column)
      row=$row$input$rowSep
    else
    #if we didnt reach final column, we just put the normal field separator '|'
      row=$row$input$sep
    fi
  done
  echo -e $row"\c" >> $tableName
  # this checks if the exit status of the previous command is 0 (success)
  if [[ $? == 0 ]]
  then
    echo "Data Inserted Successfully"
  else
    echo "Error Inserting Data into Table $tableName"
  fi
  row=""
  tablesMenu
}
function updateTable {
  echo -e "Enter Table Name: \c"
  read tableName
  echo -e "Enter Condition Column name: \c"
  read field
  fid=$(awk 'BEGIN{FS="|"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$field'") print i}}}' $tableName)
  if [[ $fid == "" ]]
  then
    echo "Not Found"
    tablesMenu
  else
    echo -e "Enter Condition Value: \c"
    read value
    res=$(awk 'BEGIN{FS="|"}{if ($'$fid'=="'$value'") print $'$fid'}' $tableName 2>>./.error.log)
    if [[ $res == "" ]]
    then
      echo "Value Not Found"
      tablesMenu
    else
      echo -e "Enter field name to set: \c"
      read setField
      setFid=$(awk 'BEGIN{FS="|"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$setField'") print i}}}' $tableName)
      if [[ $setFid == "" ]]
      then
        echo "Not Found"
        tablesMenu
      else
        echo -e "Enter new value to set: \c"
        read newValue
        NR=$(awk 'BEGIN{FS="|"}{if ($'$fid' == "'$value'") print NR}' $tableName 2>>./.error.log)
        oldValue=$(awk 'BEGIN{FS="|"}{if(NR=='$NR'){for(i=1;i<=NF;i++){if(i=='$setFid') print $i}}}' $tableName 2>>./.error.log)
        echo $oldValue
        sed -i ''$NR's/'$oldValue'/'$newValue'/g' $tableName 2>>./.error.log
        echo "Row Updated Successfully"
        tablesMenu
      fi
    fi
  fi
}
function selectMenu {
  echo -e "\n\n+---------------Select Menu--------------------+"
  echo "| 1. Select All Columns of a Table              |"
  echo "| 2. Select Specific Column from a Table        |"
  echo "| 3. Select From Table under condition          |"
  echo "| 4. Aggregate Function for a Specific Column   |"
  echo "| 5. Back To Tables Menu                        |"
  echo "| 6. Back To Main Menu                          |"
  echo "| 7. Exit                                       |"
  echo "+----------------------------------------------+"
  echo -e "Enter Choice: \c"
  read ch
  case $ch in
    1) selectAll ;;
    2) selectCol ;;
    3) clear; selectCon ;;
    4) ;;
    5) clear; tablesMenu ;;
    6) clear; cd ../.. 2>>./.error.log; mainMenu ;;
    7) exit ;;
    *) echo " Wrong Choice " ; selectMenu;
  esac
}
function selectAll {
  echo -e "Enter Table Name: \c"
  read tableName
  column -t -s '|' $tableName 2>>./.error.log
  if [[ $? != 0 ]]
  then
    echo "Error Displaying Table $tableName"
  fi
  selectMenu
}
function deleteFromTable {
  #-e option enables the interpretation of backslash escape sequences
  #/c so that we input on the same line
  echo -e "Enter Table Name: \c"
  read tName
  echo -e "Enter Condition Column name: \c"
  read field
  #checks if the field name is present
  fid=$(awk 'BEGIN{FS="|"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$field'") print i}}}' $tName)
  #if the fid is emty, no result is found
  if [[ $fid == "" ]]
  then
    echo "Not Found"
    tablesMenu
  else
  #enters the condition this field equals to delete
    echo -e "Enter Condition Value: \c"
    read val
    res=$(awk 'BEGIN{FS="|"}{if ($'$fid'=="'$val'") print $'$fid'}' $tName 2>>./.error.log)
    if [[ $res == "" ]]
    then
      echo "Value Not Found"
      tablesMenu
    else
    #if the result is not empty, we find the row number where this result is found
      NR=$(awk 'BEGIN{FS="|"}{if ($'$fid'=="'$val'") print NR}' $tName 2>>./.error.log)
      #we then delete this row using sed and give it the row number with 'd' command
      sed -i ''$NR'd' $tName 2>>./.error.log
      echo "Row Deleted Successfully"
      tablesMenu
    fi
  fi
}

function selectCol {
  echo -e "Enter Table Name: \c"
  read tName
  echo -e "Enter Column Number: \c"
  read colNum
  awk 'BEGIN{FS="|"}{print $'$colNum'}' $tName
  selectMenu
}


function selectCon {
# print a menu with options for the user to select from
  echo -e "\n\n+--------Select Under Condition Menu-----------+"
  echo "| 1. Select All Columns Matching Condition    |"
  echo "| 2. Select Specific Column Matching Condition|"
  echo "| 3. Back To Selection Menu                   |"
  echo "| 4. Back To Main Menu                        |"
  echo "| 5. Exit                                     |"
  echo "-----------------------------------------------"
  echo -e "Enter Choice: \c"
#read input from user and store to ch
  read ch
#switch depending on user input it calls function and clears
  case $ch in
    1) clear; allCond ;;
    2) clear; specCond ;;
    3) clear; selectCon ;;
    4) clear; cd ../.. 2>>./.error.log; mainMenu ;;
    5) exit ;;
    *) echo " Wrong Choice " ; selectCon;
  esac
}

function allCond {
  echo -e "Select all columns from TABLE Where Condition \n"
  echo -e "Enter Table Name: \c"
  read tName
  echo -e "Enter required FIELD name: \c"
  read field
  #search for fid  in the first row of the table and searches for the field If found, it prints its column number that will be stored in the variable fid
  fid=$(awk 'BEGIN{FS="|"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$field'") print i}}}' $tName)
  #if there isnt a field that exists by that name print not found and call selectcon function else print operators and read user input
  if [[ $fid == "" ]]
  then
    echo "Not Found"
    selectCon
  else
    echo -e "\nSupported Operators: [==, !=, >, <, >=, <=] \nSelect OPERATOR: \c"
    read op
    if [[ $op == "==" ]] || [[ $op == "!=" ]] || [[ $op == ">" ]] || [[ $op == "<" ]] || [[ $op == ">=" ]] || [[ $op == "<=" ]]
    then
      echo -e "\nEnter required VALUE: \c"
      read val
    #search for rows in table where value in $fid matches the inputs $op and $val, column formats the output into a table with a | separator. The output stored in res.
      res=$(awk 'BEGIN{FS="|"}{if ($'$fid$op$val') print $0}' $tName 2>>./.error.log |  column -t -s '|')
      if [[ $res == "" ]]
      then
        echo "Value Not Found"
        selectCon
      else
    #If rows were found print rows in a table 
        awk 'BEGIN{FS="|"}{if ($'$fid$op$val') print $0}' $tName 2>>./.error.log |  column -t -s '|'
        selectCon
      fi
    else
      echo "Unsupported Operator\n"
      selectCon
    fi
  fi
}

function specCond {
  echo -e "Select specific column from TABLE Where Condition \n"
  echo -e "Enter Table Name: \c"
  read tName
  echo -e "Enter required FIELD name: \c"
  read field
  #search for fid of the depending on user in the first row of the table and searches for $field. If found, it prints column number that is stored in fid.
  fid=$(awk 'BEGIN{FS="|"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$field'") print i}}}' $tName)
  if [[ $fid == "" ]]
  then
    echo "Not Found"
    selectCon
  else
    echo -e "\nSupported Operators: [==, !=, >, <, >=, <=] \nSelect OPERATOR: \c"
    read op
    if [[ $op == "==" ]] || [[ $op == "!=" ]] || [[ $op == ">" ]] || [[ $op == "<" ]] || [[ $op == ">=" ]] || [[ $op == "<=" ]]
    then
      echo -e "\nEnter required VALUE: \c"
      read val
  #search for rows in table where the value $fid matches inputs $op and $val. It prints the specified column ($fid) of the matching rows that is then stored in res.
      res=$(awk 'BEGIN{FS="|"; ORS="\n"}{if ($'$fid$op$val') print $'$fid'}' $tName 2>>./.error.log |  column -t -s '|')
      if [[ $res == "" ]]
      then
        echo "Value Not Found"
        selectCon
      else
  #If rows were found, it prints $fid of the matching rows in a table and then calls selectCon function.
        awk 'BEGIN{FS="|"; ORS="\n"}{if ($'$fid$op$val') print $'$fid'}' $tName 2>>./.error.log |  column -t -s '|'
        selectCon
      fi
    else
      echo "Unsupported Operator\n"
      selectCon
    fi
  fi
}

mainMenu
