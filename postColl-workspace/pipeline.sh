#!/bin/bash

isInt="^[0-9]+$"
Red="\e[0;31m"
Green="\e[0;32m"
Yellow="\e[0;33m"
resetColor="\e[0m"
SAXON="../../collationWorkspace/xslt/SaxonHE12-0J/saxon-he-12.0.jar"

checkInput(){
  chunk=$1
  while ! [[ "$chunk" =~ $isInt ]] || [[ $chunk -lt 1 ]] || [[ $chunk -gt 33 ]]
  do
    if ! [[ "$chunk" =~ $isInt ]]; then
      echo -e "${Red}Invalid input! Your input not a whole number.${resetColor}"
    elif [ "$chunk" -lt 1 ]; then
      echo -e "${Red}Invalid input! Your input is less than 1. ${resetColor}"
    elif [ "$chunk" -gt 33 ]; then
      echo -e "${Red}Invalid input! Your input is larger than 33. ${resetColor}"
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
fileExist(){
  fileName=$1
  if [ ! -f "$fileName" ]; then
    echo -e "${Red}Oops! $fileName DOES NOT exist!${resetColor}"
    exit 1
  else
    echo -e "${Green}$fileName is generated!${resetColor}"
  fi
}

postProcessColl(){
  xslArr=("P1-bridgeEditionConstructor.xsl"
  "P2-bridgeEditionConstructor.xsl"
  "P3-bridgeEditionConstructor.xsl"
#  "P3.5-bridgeEditionConstructor.xsl"
  "P4Sax-raiseBridgeElems.xsl" # 5
  "P5-Pt1-SegTrojans.xsl"
  "P5-Pt2PlantFragSegMarkers.xsl"
  "P5-Pt3MedialSTARTSegMarkers.xsl"
  "P5-Pt4MedialENDSegMarkers.xsl"
  #"P5-Pt5raiseSegElems.xsl" # 10
  #"P5_SpineGenerator.xsl"
  #"spineAdjustor.xsl"
  #"edit-distance/extractCollationData.xsl"
  )
  pipelineArr=("collated-data" "P1-output" "P2-output" "P3-output" # "P3.5-output"
  "P4-output" "preP5a-output" "preP5b-output" "preP5c-output" "preP5d-output" #"P5-output"
  #"subchunked_standoff_Spine" "preLev_standoff_Spine"
  )
  # start processing
  for (( i=0; i < ${#xslArr[@]}; i++ ))
  do
    echo -e "${Yellow}Run ${xslArr[i]}${resetColor}"
    echo -e "${Yellow}input: ${pipelineArr[$i]}, output: ${pipelineArr[$i+1]}${resetColor}"
    java -jar $SAXON -xsl:"${xslArr[$i]}" -s:"${xslArr[0]}" -t
  done

  echo -e "${Yellow}Run P5-Pt5raiseSegElems.xsl${resetColor}"
  echo -e "${Yellow}input: preP5d-output, output: P5-output${resetColor}"
  java -jar $SAXON -s:preP5d-output -xsl:P5-Pt5raiseSegElems.xsl -o:P5-output -t

  echo -e "${Yellow}Run P5_SpineGenerator.xsl${resetColor}"
  echo -e "${Yellow}input: P1-output, output: subchunked_standoff_Spine${resetColor}"
  java -jar $SAXON -s:P1-output -xsl:P5_SpineGenerator.xsl -o:subchunked_standoff_Spine -t

  for xml in subchunked_standoff_Spine/*.xml
  do
    mv "$xml" "${xml/P1_/spine_}"
  done

  echo -e "${Yellow}Phase 6: Prepare the “spine” of the variorum${resetColor}"
  echo -e "${Yellow}intput: subchunked_standoff_Spine, output: preLev_standoff_Spine${resetColor}"
  java -jar $SAXON -s:subchunked_standoff_Spine -xsl:spineAdjustor.xsl -o:. -t

  echo -e "${Yellow}Run extractCollationData.xsl in edit-distance${resetColor}"
  echo -e "${Yellow}input: preLev_standoff_Spine, output: edit-distance/spineData.txt${resetColor}"
  cd edit-distance || exit
  java -jar ../$SAXON -s:extractCollationData.xsl -xsl:extractCollationData.xsl -o:.  -t

  echo -e "${Yellow}Convert spineData.txt to ASCII format${resetColor}"
  rm spineData-ascii.txt
  iconv -c -f UTF-8 -t ascii//TRANSLIT spineData.txt  > spineData-ascii.txt
  fileExist spineData-ascii.txt

  echo -e "${Yellow}Run python LevenCalc_toXML.py${resetColor}"
  rm FV_LevDists-weighted.xml
  python3 LevenCalc_toXML.py
  fileExist FV_LevDists-weighted.xml
  # shellcheck disable=SC2103
  cd ..
  echo -e "${Yellow}Run spine_addLevWeights.xsl${resetColor}"
  echo -e "${Yellow}input: preLev_standoff_Spine, output: standoff_Spine${resetColor}"
  java -jar $SAXON -xsl:spine_addLevWeights.xsl -s:preLev_standoff_Spine -o:. -t

#  echo -e "${Yellow}Run spineEmptyWitnessPatch.xsl${resetColor}"
#  echo -e "${Yellow}input: standoff_Spine, output: fv-data/standoff_Spine${resetColor}"
#  java -jar $SAXON -xsl:spineEmptyWitnessPatch.xsl -s:standoff_Spine -o:. -t

  echo -e "${Yellow}Trimming White Space${resetColor}"
  echo -e "${Yellow}input: P5-output, output: P5-trimmedWS${resetColor}"
  java -jar saxon.jar -s:P5-output -xsl:whiteSpaceReducer.xsl -o:P5-trimmedWS -t

#  echo -e "${Yellow}Packaging collated edition files${resetColor}"
#  ./migrateP5msColl.sh
#  ./migrateP5msColl-tws.sh
}

main(){
  allArr=("collated-data" "P1-output" "P2-output" "P3-output" # "P3.5-output"
  "P4-output" "preP5a-output" "preP5b-output" "preP5c-output" "preP5d-output" "P5-output"
  "subchunked_standoff_Spine" "preLev_standoff_Spine" # "edit-distance/spineData.txt"
  "standoff_Spine"
  )
  # reset output folders
  for (( i=0; i < ${#allArr[@]}; i++ ))
  do
    rm -r "${allArr[$i]}"
  done
  for (( i=0; i < ${#allArr[@]}; i++ ))
  do
    mkdir "${allArr[$i]}"
  done

  echo -e "${Yellow}Welcome to the Frankenstein Collation Station!${resetColor} "
  read -p "Are you working with ONLY ONE collation chunk? Enter [y/n]: " opt
  while [[ $opt =~ $isInt ]]
  do
    echo -e "${Red}Invalid input! Your input is an integer.${resetColor}"
    read -p "Are you working with ONLY ONE collation chunk? Enter [y/n]: " opt
  done
  if [[ $opt == "Y" ]] || [[ $opt == "y" ]]; then
    read -p "Enter only the whole number of the chunk between 1 and 33: " chunk
    checkInput "$chunk"
    chunk=$?
    # Process chunk
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
  postProcessColl
}

main