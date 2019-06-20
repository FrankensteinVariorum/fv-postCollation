declare default element namespace "http://www.tei-c.org/ns/1.0";
let $spineFiles := collection('standoff_Spine')
let $apps := $spineFiles//app
let $editCalcs := $apps[not(@n="")]/@n/number()
let $count := count($editCalcs)
let $avg := $editCalcs => avg()
return $avg
(: We see they range from 2 to 6000, 
with only 8 instances above 1000 in a total of 1653 
app elements (moments of variance across the 5 editions) :)



