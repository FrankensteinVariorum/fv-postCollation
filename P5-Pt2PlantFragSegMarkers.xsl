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
  2018-10-13: We need to add MEDIAL segs in this stylesheet, too, where segs are broken into three parts.
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
       <xsl:choose>
       <!--When the START ID stands a level above the matching END marker (END marker is child of a following-sibling element node).  --> 
           <xsl:when test="following-sibling::*/seg[@part='F' and substring-before(@th:eID, '__') = $matchID]">
               <xsl:apply-templates select="following-sibling::node()[following-sibling::*/seg[@part='F' and substring-before(@th:eID, '__') = $matchID]]"/>
     <seg th:eID="{@th:sID}" part="{@part}"/>
               <xsl:apply-templates select="following-sibling::*[seg[@part='F' and substring-before(@th:eID, '__') = $matchID]]"/>
               <xsl:apply-templates select="following-sibling::*[seg[@part='F' and substring-before(@th:eID, '__') = $matchID]]/following-sibling::node()"/>
         </xsl:when>  
           
       </xsl:choose> 
        
    </xsl:template>
    
  <!--  <xsl:template match="*[child::seg[@part]]">
          <xsl:element name="{name()}">
              <xsl:copy-of select="@*"/>
              <xsl:apply-templates/>
         <xsl:if test="seg[@part='I' and @th:sID]">
           <xsl:choose>
               <!-\-The first-part seg could be in the hierarchy level above (most likely in the div above the paragraphs). In this case, we need to make sure the end marker is not in the last position, but precedes the element that contains the close marker. -\->
               <xsl:when test="seg[@part='I' and substring-before(@th:sID, '__') = following-sibling::*/seg[@part='F' and @th:eID]/substring-before(@th:eID, '__')]">
        <xsl:apply-templates select="node()[preceding-sibling::seg[@part='I' ]]"           
                   
               </xsl:when>
           </xsl:choose>   
         </xsl:if>
          </xsl:element>
      </xsl:template>-->
</xsl:stylesheet>


