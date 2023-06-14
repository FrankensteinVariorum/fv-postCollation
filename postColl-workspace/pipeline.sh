#!/bin/bash

isInt="^[0-9]+$"
Red="\e[0;31m"
Green="\e[0;32m"
Yellow="\e[0;33m"
White="\e[0m"
SAXON="../../collationWorkspace/xslt/SaxonHE12-0J/saxon-he-12.0.jar"

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
fileExist(){
  fileName=$1
  if [ ! -f "$fileName" ]; then
    echo -e "${Red}Oops! $fileName DOES NOT exist!${White}"
    exit 1
  else
    echo -e "${Green}$fileName is generated!${White}"
  fi
}

postProcessColl(){
  xslArr=("P1-bridgeEditionConstructor.xsl"
  "P2-bridgeEditionConstructor.xsl"
  "P3-bridgeEditionConstructor.xsl"
  "P4Sax-raiseBridgeElems.xsl" 
  "P5-Pt1-SegTrojans.xsl" # 5
  "P5-Pt2PlantFragSegMarkers.xsl"
  "P5-Pt3MedialSTARTSegMarkers.xsl"
  "P5-Pt4MedialENDSegMarkers.xsl"
  "P5-Pt5raiseSegElems.xsl" 
  "P5-Pt6spaceHandling.xsl" # 10
  "P6-Pt1-combine.xsl"
  "P6-Pt2-simplify-chapAnchors.xsl"
  "P6-Pt3-chapChunking.xsl"
  # "P5_SpineGenerator.xsl"
  #"spineAdjustor.xsl"
  #"edit-distance/extractCollationData.xsl"
  )
  pipelineArr=("collated-data" "P1-output" "P2-output" "P3-output"
  "P4-output" "preP5a-output" "preP5b-output" "preP5c-output" "preP5d-output" "preP5e-output" "P5-output" "P6-Pt1"
  "P6-Pt2" "P6-Pt3"
  #"subchunked_standoff_Spine" "preLev_standoff_Spine"
  )
  # start processing
  for (( i=0; i < ${#xslArr[@]}; i++ ))
  do
    echo -e "${Yellow}Run ${xslArr[i]}${White}"
    echo -e "${Yellow}input: ${pipelineArr[$i]}, output: ${pipelineArr[$i+1]}${White}"
    java -jar $SAXON -xsl:"${xslArr[$i]}" -s:"${xslArr[$i]}" -t
  done

  echo -e "${Yellow}Run P5_SpineGenerator.xsl${White}"
  echo -e "${Yellow}input: P1-output, output: subchunked_standoff_Spine${White}"
  java -jar $SAXON -s:P1-output -xsl:P5_SpineGenerator.xsl -o:subchunked_standoff_Spine -t

  for xml in subchunked_standoff_Spine/*.xml
  do
    mv "$xml" "${xml/P1_/spine_}"
  done

  echo -e "${Yellow}Phase 7: Prepare the “spine” of the variorum${White}"
  echo -e "${Yellow}intput: subchunked_standoff_Spine, output: preLev_standoff_Spine${White}"
  java -jar $SAXON -s:subchunked_standoff_Spine -xsl:spineAdjustor.xsl -o:. -t

  echo -e "${Yellow}Run extractCollationData.xsl in edit-distance${White}"
  echo -e "${Yellow}input: preLev_standoff_Spine, output: edit-distance/spineData.txt${White}"
  cd edit-distance || exit
  java -jar ../$SAXON -s:extractCollationData.xsl -xsl:extractCollationData.xsl -o:.  -t
  fileExist spineData.txt

  echo -e "${Yellow}Convert spineData.txt to ASCII format${White}"
  rm spineData-ascii.txt
  iconv -c -f UTF-8 -t ascii//TRANSLIT spineData.txt  > spineData-ascii.txt
  fileExist spineData-ascii.txt

  echo -e "${Yellow}Run python LevenCalc_toXML.py${White}"
  rm FV_LevDists-weighted.xml
  python3 LevenCalc_toXML.py
  fileExist FV_LevDists-weighted.xml
  cd ..
  echo -e "${Yellow}Run spine_addLevWeights.xsl${White}"
  echo -e "${Yellow}input: preLev_standoff_Spine, output: standoff_Spine${White}"
  java -jar $SAXON -xsl:spine_addLevWeights.xsl -s:preLev_standoff_Spine -o:. -t

 echo -e "${Yellow}Run spineEmptyWitnessPatch.xsl${White}"
 echo -e "${Yellow}input: standoff_Spine, output: fv-data/standoff_Spine${White}"
 java -jar $SAXON -xsl:spineEmptyWitnessPatch.xsl -s:standoff_Spine -o:. -t

# echo -e "${Yellow}Trimming White Space${White}"
# echo -e "${Yellow}input: P5-output, output: P5-trimmedWS${White}"
# java -jar saxon.jar -s:P5-output -xsl:whiteSpaceReducer.xsl -o:P5-trimmedWS -t

#  echo -e "${Yellow}Packaging collated edition files${White}"
#  ./migrateP5msColl.sh
}

main(){
  allArr=("collated-data" "P1-output" "P2-output" "P3-output" 
  "P4-output" "preP5a-output" "preP5b-output" "preP5c-output" "preP5d-output" "preP5e-output" "P5-output" "P5-trimmedWS"  "P6-Pt1"
  "P6-Pt2" "P6-Pt3" 
  "subchunked_standoff_Spine" "preLev_standoff_Spine" # "edit-distance/spineData.txt"
  "standoff_Spine"
  )

  # reset output folders======
  for (( i=0; i < ${#allArr[@]}; i++ ))
  do
    rm -r "${allArr[$i]}"
    mkdir "${allArr[$i]}"
  done
  #====================

  echo -e "${Yellow}Welcome to the Frankenstein Collation Station!${White} "
  read -p "Are you working with ONLY ONE collation chunk? Enter [y/n]: " opt
  while [[ $opt =~ $isInt ]]
  do
    echo -e "${Red}Invalid input! Your input is an integer.${White}"
    read -p "Are you working with ONLY ONE collation chunk? Enter [y/n]: " opt
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
  postProcessColl
}

main