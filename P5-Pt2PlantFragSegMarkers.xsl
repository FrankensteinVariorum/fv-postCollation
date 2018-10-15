<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xpath-default-namespace="http://www.tei-c.org/ns/1.0"  xmlns:pitt="https://github.com/ebeshero/Pittsburgh_Frankenstein"
xmlns:mith="http://mith.umd.edu/sc/ns1#"  xmlns:th="http://www.blackmesatech.com/2017/nss/trojan-horse"
    xmlns="http://www.tei-c.org/ns/1.0"  
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="3.0">

<xsl:mode on-no-match="shallow-copy"/>
    <xsl:variable name="preP5a-coll" as="document-node()+" select="collection('preP5a-output/?select=*.xml')"/>
    <xsl:variable name="testerFile" as="document-node()" select="doc('preP5a-output/P5-f1831_C07.xml')"/>
<!--2018-10-10 ebb: Bridge Construction Phase 5b: Here we are dealing with "stranded" or fragmented segs that are in between up-raised elements in the edition files. This XSLT plants medial <seg/> start or end "marker" tags prior to upraising the seg elements.
  2018-10-15: We will need to add medial seg elements where there are multiple element nodes in between start-marker and end-marker pairs. We'll do this in the next stylesheet in the series to avoid ambiguous rule matches. 
    -->    
   <xsl:template match="/">
       <!-- Change back to $preP5a-coll//TEI when done testing -->
       <xsl:for-each select="$testerFile//TEI">
           <xsl:variable name="currentP5File" as="element()" select="current()"/>
           <xsl:variable name="filename" as="xs:string" select="tokenize(base-uri(), '/')[last()]"/>
         <xsl:variable name="chunk" as="xs:string" select="tokenize(base-uri(), '/')[last()] ! substring-before(., '.') ! substring-after(., '_')"/> 

           <xsl:result-document method="xml" indent="yes" href="preP5b-TESTERoutput/5b--{$filename}">
               <TEI xmlns="http://www.tei-c.org/ns/1.0"                 xmlns:pitt="https://github.com/ebeshero/Pittsburgh_Frankenstein" xmlns:mith="http://mith.umd.edu/sc/ns1#"  xmlns:th="http://www.blackmesatech.com/2017/nss/trojan-horse">
         <xsl:copy-of select="descendant::teiHeader" copy-namespaces="no"/>
        <text>
            <body>
                <xsl:apply-templates select="descendant::div[@type='collation']"/>
            </body>
        </text>
        </TEI>
         </xsl:result-document>
       </xsl:for-each>      
   </xsl:template>
    <!--FRAGMENT PART I SEGs w/ (all start markers without following-sibling end markers) -->
    <xsl:template match="seg[@part='I' and @th:sID]">
<xsl:copy-of select="."/>
        <xsl:variable name="matchID" as="xs:string" select="substring-before(@th:sID, '__')"/>
           <!--End marker for closing part will always be on the following:: axis. -->
 <xsl:copy-of select="following-sibling::node()[following::seg[@part='F' and substring-before(@th:eID, '__') = $matchID]]"/>
     <seg th:eID="{@th:sID}" part="{@part}"/>
    </xsl:template>
    <!--FRAGMENT PART F (terminal) segs: All end-markers without preceding-sibling start-markers -->
    <xsl:template match="seg[@part='F' and @th:eID]">
        <xsl:variable name="matchID" as="xs:string" select="substring-before(@th:eID, '__')"/>
        <!--Starting-part marker will always be on the preceding:: axis. -->
        <seg th:sID="{@th:eID}" part="{@part}"/> 
        <xsl:copy-of select="preceding-sibling::node()[preceding::seg[@part='I' and substring-before(@th:sID, '__') = $matchID]]"/>
        <xsl:copy-of select="."/>  
    </xsl:template>
    <!--Setting MEDIAL marker pairs. This finds the FIRST element node in a medial marker position and places a medial start marker before it, then copies the following-sibling nodes that share the same preceding::seg and don't contain its end marker.-->
    <!-- 
    //*[not(self::seg)][preceding::seg[1][@th:eID and @part='I']][not(descendant::seg[1][@th:sID and @part='F' and substring-before(@th:sID, '__') = substring-before( ./preceding::seg[1]/@th:eID, '__')])]
    -->
    <xsl:template match="*[not(self::seg)][preceding::*[1][@th:sID and @part='I']][not(descendant::seg[1][@th:eID and @part='F' and substring-before(@th:eID, '__') = substring-before(current()/preceding::*[1]/@th:sID, '__')]) and not(ancestor::*[preceding::*[1][@th:sID and @part='I' and substring-before(@th:sID, '__') = substring-before(current()/preceding::*[1]/@th:sID, '__') ]])]">
        <!--NOTE: This matches on an element node (not a seg) whose very first preceding element is the end of a START FRAG. (The preceding::*[1] ensures this is the very first preceding element.) We isolate that element and construct a first medial seg marker before it. We have to exclude those elements that hold the END marker as descendants and also element descendants of matching nodes (like a <pb/> child of a matching <p>) because these share the preceding:: axis distinction and count as having a first preceding element meeting our condition.  -->
     <xsl:variable name="matchID" as="xs:string" select="substring-before(preceding::*[1][@part='I']/@th:sID, '__')"/>
    <seg part="M" th:sID="{$matchID}__M"/>
    <xsl:copy-of select="."/>
    </xsl:template>
  <!--The next template rule plants a medial end-marker just after the last element node whose very first following seg is a member of a fragmented seg final-pair.  -->
    <xsl:template match="*[not(self::seg)][following::*[1][self::seg[@th:eID and @part='F']] or descendant::seg[1][@th:eID and @part='F']][not(descendant::seg[1][@th:sID and @part='I' and substring-before(@th:sID, '__') = substring-before(current()/following::seg[1]/@th:eID, '__')]) and not(ancestor::*[following::seg[1][@th:eID and @part='F' and substring-before(@th:eID, '__') = substring-before(current()/following::seg[1]/@th:eID, '__') ]])]">
        <xsl:variable name="matchID" as="xs:string" select="substring-before(following::seg[1][@part='F']/@th:eID, '__')"/>
    <xsl:copy-of select="."/>    
     <seg part="M" th:eID="{$matchID}__M"/>  
    </xsl:template>
    
<!--Suppressing duplicates of copied nodes in the above templates -->
    <!--Suppresses nodes that come after initial start-markers -->
  <xsl:template match="node()[preceding-sibling::seg[@part='I' and @th:sID] and following::seg[1][@part='F'][substring-before(@th:eID, '__') = substring-before(current()/preceding-sibling::seg[1][@part='I']/@th:sID, '__')]]"/> 
    <!--Suppresses nodes that come before terminal end-markers -->
    <xsl:template match="node()[following-sibling::seg[@part='F' and @th:eID] and preceding::seg[1][@part='I' and substring-before(@th:sID, '__') = substring-before(current()/following-sibling::seg[1][@part='F']/@th:eID, '__')]]"/>
</xsl:stylesheet>


