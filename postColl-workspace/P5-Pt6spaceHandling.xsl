<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:th="http://www.blackmesatech.com/2017/nss/trojan-horse" exclude-result-prefixes="xs th"
  version="3.0">
  <!--2019-06-27 ebb: We need to add a tei: prefixed namespace in addition to the default namesapce to our output variorum edition files to support use of xml pointers in the Variorum edition, 
  so I am intervening here to add it.-->
  <!--2018-07-30 ebb: Run this with Saxon at command line to raise paired seg markers, using:
    java -jar saxon.jar -s:preP5e-output/ -xsl:P5-Pt6spaceHandling.xsl -o:P5-output/ 
    -->
 
  
  <xsl:mode on-no-match="shallow-copy"/>
  
  <xsl:template match="*[child::seg]//text()">
     <xsl:choose>
       <xsl:when test="following-sibling::*[1][name() = 'seg'] and not(preceding-sibling::*[1][name() = 'seg'])">
         <xsl:copy/><xsl:text> </xsl:text>
   
       </xsl:when>
       <xsl:when test="preceding-sibling::*[1][name() = 'seg'] and not(following-sibling::*[1][name() = 'seg'])">
         <xsl:text> </xsl:text><xsl:copy/>

       </xsl:when>
       <xsl:when test="preceding-sibling::*[1][name() = 'seg'] and following-sibling::*[1][name() = 'seg']">
         <xsl:text> </xsl:text><xsl:copy/><xsl:text> </xsl:text>
       </xsl:when>
       <xsl:otherwise>
         <xsl:copy/>
       </xsl:otherwise>
       
     </xsl:choose>      

  </xsl:template>
  
   
</xsl:stylesheet>
