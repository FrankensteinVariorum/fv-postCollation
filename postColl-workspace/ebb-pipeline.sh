#!/bin/bash

# ----- global variables -----
isInt="^[0-9]+$"
Red="\e[0;31m"
Green="\e[0;32m"
Yellow="\e[0;33m"
White="\e[0m"
SAXON="../../collationWorkspace/xslt/SaxonHE12-0J/saxon-he-12.0.jar"
message="-t" 

# ----- functions -----
checkInput(){
  # check the user input is valid, print the message, and allow to re-input
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
  # copy collation chunks from collationWorkspace
  chunk=$1
  if [ ${#chunk} -lt 2 ]; then
    chunk="0$chunk"
  fi
  chunk="C$chunk"
  cp "../../collationWorkspace/collationChunks/$chunk/output/collation_$chunk-complete.xml" collated-data
  mv "collated-data/collation_$chunk-complete.xml" "collated-data/collation_$chunk.xml"
}
fileExist(){
  # check if the file generated sucessfully
  fileName=$1
  if [ ! -f "$fileName" ]; then
    echo -e "${Red}Oops! $fileName DOES NOT exist!${White}"
    exit 1
  else
    echo -e "${Green}$fileName is generated!${White}"
  fi
}
postProcessColl(){
  # this array includes xslt files to run
  xslArr=("P1-bridgeEditionConstructor.xsl"
  "P2-bridgeEditionConstructor.xsl"
  "P3-bridgeEditionConstructor.xsl"
  "P4Sax-raiseBridgeElems.xsl" 
  "P5-Pt1-SegTrojans.xsl" # 5
  "P5-Pt2-PlantFragSegMarkers.xsl"
  "P5-Pt3-MedialSTARTSegMarkers.xsl"
  "P5-Pt4-MedialENDSegMarkers.xsl"
  "P5-Pt5-raiseSegElems.xsl" 
  "P5-Pt6-spaceHandling.xsl" # 10
  "P6-Pt1-combine.xsl"
  "P6-Pt2-simplify-chapAnchors.xsl"
  "P6-Pt3-chapChunking.xsl"
  "P6-SpineGenerator.xsl"
  #"spineAdjustor.xsl"
  #"edit-distance/extractCollationData.xsl"
  )
  # this array includes the pipeline directories
  pipelineArr=("collated-data" "P1-output" "P2-output" "P3-output" "P4-output" 
  "P5-Pt1-output" "P5-Pt2-output" "P5-Pt3-output" "P5-Pt4--output" "P5-Pt5-output" "P5-Pt6-output" 
  "P6-Pt1-output" "P6-Pt2-output" "P6-Pt3-output"
  "subchunked_standoff_Spine" #"preLev_standoff_Spine"
  )
  # start processing
  for (( i=0; i < ${#xslArr[@]}; i++ ))
  do
    echo -e "${Yellow}Run ${xslArr[i]}${White}"
    if [[ $i -eq $(( ${#xslArr[@]} - 1 )) ]]; then
     echo -e "${Yellow}input: P1-output: ${pipelineArr[$i+1]}${White}"
    else
     echo -e "${Yellow}input: ${pipelineArr[$i]}, output: ${pipelineArr[$i+1]}${White}"
    fi
    java -jar $SAXON -xsl:"${xslArr[$i]}" -s:"${xslArr[$i]}" ${message}
  done  

  # rename fMS chapter files
  cd P6-Pt3-output
  mv "fMS_box_c56_chapter.xml" "fMS_box_c56_chapter_3.xml"
  mv "fMS_box_c57_vol_ii.xml" "fMS_box_c57_vol_ii_chap_1.xml"
  mv "fMS_box_c57_chap.xml" "fMS_box_c57_chap_2.xml"
  cd ..

  for xml in subchunked_standoff_Spine/*.xml
  do
    mv "$xml" "${xml/P1_/spine_}"
  done

  echo -e "${Yellow}Phase 7: Prepare the “spine” of the variorum${White}"
  echo -e "${Yellow}Run spineAdjustor.xsl${White}"
  echo -e "${Yellow}intput: subchunked_standoff_Spine, output: preLev_standoff_Spine${White}"
  java -jar $SAXON -s:spineAdjustor.xsl -xsl:spineAdjustor.xsl 

  echo -e "${Yellow}Run extractCollationData.xsl in edit-distance${White}"
  echo -e "${Yellow}input: preLev_standoff_Spine, output: edit-distance/spineData.txt${White}"
  cd edit-distance || exit
  java -jar ../$SAXON -s:extractCollationData.xsl -xsl:extractCollationData.xsl  ${message}
  fileExist spineData.txt

  echo -e "${Yellow}Convert spineData.txt to ASCII format${White}"
  rm spineData-ascii.txt
  iconv -c -f UTF-8 ${message} ascii//TRANSLIT spineData.txt  > spineData-ascii.txt
  fileExist spineData-ascii.txt

  echo -e "${Yellow}Run python LevenCalc_toXML.py${White}"
  rm FV_LevDists-weighted.xml
  python3.11 LevenCalc_toXML.py
  fileExist FV_LevDists-weighted.xml

  echo -e "${Yellow}Run LevWeight-Simplification.xsl${White}"
  rm FV_LevDists-simplified.xml
  java -jar ../$SAXON -xsl:LevWeight-Simplification.xsl -s:FV_LevDists-weighted.xml -o:FV_LevDists-simplified.xml ${message}
  fileExist FV_LevDists-simplified.xml
  cd ..

  echo -e "${Yellow}Run spine_addLevWeights.xsl${White}"
  echo -e "${Yellow}input: preLev_standoff_Spine, output: standoff_Spine${White}"
  java -jar $SAXON -xsl:spine_addLevWeights.xsl -s:spine_addLevWeights.xsl ${message}

 echo -e "${Yellow}Packaging chapter files${White}"
 # Copy separate directories to fv-data repo
 echo -e "Copy ${Yellow}P6-Pt3-output${White} to ${Yellow}fv-data/2023-variorum-chapters${White}"
 cp -R P6-Pt3-output/*.xml ../../fv-data/2023-variorum-chapters
 echo -e "Copy ${Yellow}standoff_Spine${White} to ${Yellow}fv-data/2023-standoff_Spine${White}"
 cp -R standoff_Spine/*.xml ../../fv-data/2023-standoff_Spine
}

# ----- main function -----
main(){
  allArr=("collated-data" "P1-output" "P2-output" "P3-output" "P4-output" 
  "P5-Pt1-output" "P5-Pt2-output" "P5-Pt3-output" "P5-Pt4-output" "P5-Pt5-output" "P5-Pt6-output"
  "P6-Pt1-output" "P6-Pt2-output" "P6-Pt3-output" 
  "subchunked_standoff_Spine" "preLev_standoff_Spine" #"edit-distance/spineData.txt"
  "standoff_Spine" "../../fv-data/2023-variorum-chapters" "../../fv-data/2023-standoff_Spine"
  )

  # reset output folders======
  echo -e "Preparing......"
  for (( i=0; i < ${#allArr[@]}; i++ ))
  do
    rm -r "${allArr[$i]}" # remove all output folders
    mkdir "${allArr[$i]}" # create all output folders
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