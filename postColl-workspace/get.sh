isInt="^[0-9]+$"
Red="\e[0;31m"
Green="\e[0;32m"
Yellow="\e[0;33m"
White="\e[0m"

checkInput(){
  chunk=$1
  while ! [[ "$chunk" =~ $isInt ]] || [[ $chunk -lt 1 ]] || [[ $chunk -gt 33 ]]
  do
    if ! [[ "$chunk" =~ $isInt ]]; then
      echo -e "${Red}Invalid input! Your input not a whole number.${White}"
    elif [ "$chunk" -lt 1 ]; then
      echo -e "${Red}Invalid input! Your input is less than 1. ${White}"
    elif [ "$chunk" -gt 33 ]; then
      echo -e "${Red}Invalid input! Your input is larger than 33. ${White}"
    fi
    read -p "Please input a whole number between 1 and 33: " chunk
  done
  return "$chunk"
}

getChunk(){
  chunk=$1
  if [ ${#chunk} -lt 2 ]; then
    chunk="0$chunk"
  fi
  chunk="C$chunk"
  cp "../../collationWorkspace/collationChunks/$chunk/output/collation_$chunk-complete.xml" collated-data
  mv "collated-data/collation_$chunk-complete.xml" "collated-data/collation_$chunk.xml"
}

echo -e "${Yellow}Welcome to get the chunks!${White} "
read -p "Are you getting ONLY ONE collation chunk? Enter [y/n]: " opt
while [[ $opt =~ $isInt ]]
do
  echo -e "${Red}Invalid input! Your input is an integer.${White}"
  read -p "Are you getting ONLY ONE collation chunk? Enter [y/n]: " opt
done
if [[ $opt == "Y" ]] || [[ $opt == "y" ]]; then
  read -p "Enter only the whole number of the chunk between 1 and 33: " chunk
  checkInput "$chunk"
  chunk=$?
  getChunk $chunk
else # If multiple chunks, then...
  echo "Enter the range of the collation chunks to output (whole numbers between 1 and 33)"
  read -p "From: " start
  checkInput "$start"
  start=$?
  read -p "To: " end
  checkInput "$end"
  end=$?
  # Process chunks
  for chunk in $(seq $start $end)
  do
    getChunk "$chunk"
  done
fi