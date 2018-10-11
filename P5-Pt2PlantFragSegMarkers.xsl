<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xpath-default-namespace="http://www.tei-c.org/ns/1.0"  xmlns:pitt="https://github.com/ebeshero/Pittsburgh_Frankenstein"
xmlns:mith="http://mith.umd.edu/sc/ns1#"  xmlns:th="http://www.blackmesatech.com/2017/nss/trojan-horse"
    xmlns="http://www.tei-c.org/ns/1.0"  
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="3.0">

<xsl:mode on-no-match="shallow-copy"/>
    <xsl:variable name="preP5a-coll" as="document-node()+" select="collection('preP5a-output/?select=*.xml')"/> 
<!--2018-10-10 ebb: Bridge Construction Phase 5b: Here we are dealing with "stranded" or fragmented segs that are in between up-raised elements in the edition files. This XSLT plants medial <seg/> start or end "marker" tags prior to upraising the seg elements.
    -->    
   <xsl:template match="/">
       <xsl:for-each select="$preP5a-coll//TEI">
           <xsl:variable name="currentP5File" as="element()" select="current()"/>
           <xsl:variable name="filename" as="xs:string" select="tokenize(base-uri(), '/')[last()]"/>
         <xsl:variable name="chunk" as="xs:string" select="tokenize(base-uri(), '/')[last()] ! substring-before(., '.') ! substring-after(., '_')"/> 

           <xsl:result-document method="xml" indent="yes" href="preP5b-output/{$filename}">
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
    <xsl:template match="*[child::seg[@part]]">
          <xsl:element name="{name()}">
              <xsl:copy-of select="@*"/>
          <xsl:if test="child::seg[1][@part and @th:eID]">
              <seg th:sID="{child::seg[1][@part and @th:eID]/@th:eID}" part="{child::seg[1][@part and @th:eID]/@part}"/>
              <xsl:apply-templates select="child::seg[1][@part and @th:eID]/preceding-sibling::node()"/>
             
              <xsl:apply-templates select="child::seg[1][@part and @th:eID]"/>
              <xsl:apply-templates select="child::seg[1][@part and @th:eID]/following-sibling::node()[not(seg[last() and @part and @th:sID]) and not(preceding-sibling::seg[@part and @th:sID and not(following-sibling::seg[@part and @th:eID])])]"/>
          </xsl:if>
              <xsl:if test="child::seg[last()][@part and @th:sID]"> 
     <xsl:apply-templates select="child::seg[last() and @part and @th:sID]"/>
                  <xsl:apply-templates select="child::seg[last() and @part and @th:sID]/following-sibling::node()"/>
                  <seg th:eID="{child::seg[last()][@part and @th:sID]/@th:sID}" part="{child::seg[last()][@part and @th:sID]/@part}"/>
              </xsl:if>
          </xsl:element>
      </xsl:template>
</xsl:stylesheet>


