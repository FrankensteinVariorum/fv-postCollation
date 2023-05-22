    allArr=("collated-data" "P1-output" "P2-output" "P3-output" # "P3.5-output"
  "P4-output" "preP5a-output" "preP5b-output" "preP5c-output" "preP5d-output" "P5-output" "P5-trimmedWS"
  "subchunked_standoff_Spine" "preLev_standoff_Spine" # "edit-distance/spineData.txt"
  "standoff_Spine")
  
  # reset output folders
  for (( i=0; i < ${#allArr[@]}; i++ ))
  do
    rm -r "${allArr[$i]}"
    mkdir "${allArr[$i]}"
  done