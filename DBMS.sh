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
