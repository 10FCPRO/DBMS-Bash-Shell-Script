
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


//Selecting Database 
function selectDB { // Enter the Database name the needs to be selected 
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

//Creating Database
function createDB {
  echo -e "Enter Database Name: \c"
  read dbName
  mkdir ./DBMS/$dbName  // The mkdir command creates a new directory with the name specified by the user, under the ./DBMS directory. 
  if [[ $? == 0 ]]
  then
    echo "Database Created Successfully"
  else
    echo "Error Creating Database $dbName"
  fi
  mainMenu
}




// This is a shell Function that renames the Database 
function DatabaseRename { 
  echo -e "Please Enter the Current Database Name: \c" // The function prompts the user to enter the current database name
  read dbName  // It reads the input using the read Command
  echo -e "Please Enter the New Database Name: \c" //The function prompts the user to enter the new database name  
  read newName // Reading 
  
  // The mv command is used to rename the directory that represents the current database.
  // The 2>> operator redirects any error messages to the .error.log file.
  mv ./DBMS/$dbName ./DBMS/$newName 2>>./.error.log
  //The function checks the exit status of the mv command using $?. If the exit status is 0,
  //the function prints "Database Renamed Successfully". Otherwise, it prints "Error Renaming Database".
  if [[ $? == 0 ]]; then
    echo "Database Renamed Successfully"
  else
    echo "Error occured in Renaming the Database"
  fi
  mainMenu
}

function dropDB {
  echo -e "Enter Database Name: \c"
  read dbName
  rm -r ./DBMS/$dbName 2>>./.error.log.  //The rm command is used to remove the directory that represents the database.
  // The -r option is used to remove the directory and its contents recursively.

  if [[ $? == 0 ]]; then
    echo "Database Dropped Successfully"
  else
    echo "Database Not found"
  fi
  mainMenu
}

//It calls the tablesMenu function. The menu has nine options, numbered from 1 to 9.
function tablesMenu {
  echo -e "\n+--------Tables Menu------------+"
  echo "| 1. Show Existing Tables       |" //displays a list of existing tables in the current directory
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

function createTable {
  echo -e "Table Name: \c"
  read tableName
  if [[ -f $tableName ]]; then
    echo "table already existed ,choose another name"
    tablesMenu
  fi
  echo -e "Number of Columns: \c"
  read colsNum
  counter=1
  sep="|"
  rSep="\n"
  pKey=""
  metaData="Field"$sep"Type"$sep"key"
  while [ $counter -le $colsNum ]
  do
    echo -e "Name of Column No.$counter: \c"
    read colName

    echo -e "Type of Column $colName: "
    select var in "int" "str"
    do
      case $var in
        int ) colType="int";break;;
        str ) colType="str";break;;
        * ) echo "Wrong Choice" ;;
      esac
    done
    if [[ $pKey == "" ]]; then
      echo -e "Make PrimaryKey ? "
      select var in "yes" "no"
      do
        case $var in
          yes ) pKey="PK";
          metaData+=$rSep$colName$sep$colType$sep$pKey;
          break;;
          no )
          metaData+=$rSep$colName$sep$colType$sep""
          break;;
          * ) echo "Wrong Choice" ;;
        esac
      done
    else
      metaData+=$rSep$colName$sep$colType$sep""
    fi
    if [[ $counter == $colsNum ]]; then
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
  echo -e "Table Name: \c"
  read tableName
  if ! [[ -f $tableName ]]; then
    echo "Table $tableName isn't existed ,choose another Table"
    tablesMenu
  colsNum=`awk 'END{print NR}' .$tableName`
  sep="|"
  rowSep="\n"
  for (( i = 2; i <= $colsNum; i++ )); do
    columnName=$(awk 'BEGIN{FS="|"}{ if(NR=='$i') print $1}' .$tableName)
    columnType=$( awk 'BEGIN{FS="|"}{if(NR=='$i') print $2}' .$tableName)
    colKey=$( awk 'BEGIN{FS="|"}{if(NR=='$i') print $3}' .$tableName)
    echo -e "$columnName ($columnType) = \c"
    read input

    # Validate Input
    if [[ $columnType == "int" ]]; then
      while ! [[ $input =~ ^[0-9]*$ ]]; do
        echo -e "invalid DataType !!"
        echo -e "$columnName ($columnType) = \c"
        read input
      done
    fi

    if [[ $colKey == "PK" ]]; then
      while [[ true ]]; do
        if [[ $input =~ ^[`awk 'BEGIN{FS="|" ; ORS=" "}{if(NR != 1)print $(('$i'-1))}' $tableName`]$ ]]; then
          echo -e "invalid input for Primary Key !!"
        else
          break;
        fi
        echo -e "$columnName ($columnType) = \c"
        read input
      done
    fi

    #Set row
    if [[ $i == $colsNum ]]; then
      row=$row$input$rowSep
    else
      row=$row$input$sep
    fi
  done
  echo -e $row"\c" >> $tableName
  if [[ $? == 0 ]]
  then
    echo "Data Inserted Successfully"
  else
    echo "Error Inserting Data into Table $tableName"
  fi
  row=""
  tablesMenu
}

function deleteFromTable {
  echo -e "Enter Table Name: \c"
  read tName
  echo -e "Enter Condition Column name: \c"
  read field
  fid=$(awk 'BEGIN{FS="|"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$field'") print i}}}' $tName)
  if [[ $fid == "" ]]
  then
    echo "Not Found"
    tablesMenu
  else
    echo -e "Enter Condition Value: \c"
    read val
    res=$(awk 'BEGIN{FS="|"}{if ($'$fid'=="'$val'") print $'$fid'}' $tName 2>>./.error.log)
    if [[ $res == "" ]]
    then
      echo "Value Not Found"
      tablesMenu
    else
      NR=$(awk 'BEGIN{FS="|"}{if ($'$fid'=="'$val'") print NR}' $tName 2>>./.error.log)
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
  echo -e "\n\n+--------Select Under Condition Menu-----------+"
  echo "| 1. Select All Columns Matching Condition    |"
  echo "| 2. Select Specific Column Matching Condition|"
  echo "| 3. Back To Selection Menu                   |"
  echo "| 4. Back To Main Menu                        |"
  echo "| 5. Exit                                     |"
  echo "+---------------------------------------------+"
  echo -e "Enter Choice: \c"
  read ch
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
  echo -e "Select all columns from TABLE Where FIELD(OPERATOR)VALUE \n"
  echo -e "Enter Table Name: \c"
  read tName
  echo -e "Enter required FIELD name: \c"
  read field
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
      res=$(awk 'BEGIN{FS="|"}{if ($'$fid$op$val') print $0}' $tName 2>>./.error.log |  column -t -s '|')
      if [[ $res == "" ]]
      then
        echo "Value Not Found"
        selectCon
      else
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
  echo -e "Select specific column from TABLE Where FIELD(OPERATOR)VALUE \n"
  echo -e "Enter Table Name: \c"
  read tName
  echo -e "Enter required FIELD name: \c"
  read field
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
      res=$(awk 'BEGIN{FS="|"; ORS="\n"}{if ($'$fid$op$val') print $'$fid'}' $tName 2>>./.error.log |  column -t -s '|')
      if [[ $res == "" ]]
      then
        echo "Value Not Found"
        selectCon
      else
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
