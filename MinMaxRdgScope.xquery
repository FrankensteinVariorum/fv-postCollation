 declare default element namespace "http://www.tei-c.org/ns/1.0";
let $frankcoll := collection('P1-output/')
let $app := $frankcoll//app
let $rdg := $frankcoll//rdg
let $strLength := $rdg/string-length()
let $maxSL := max($strLength)
let $minSL := min($strLength)
return concat('Max: ', $maxSL, '; Min: ', $minSL)
