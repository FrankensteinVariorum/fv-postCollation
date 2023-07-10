<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:th="http://www.blackmesatech.com/2017/nss/trojan-horse" exclude-result-prefixes="xs th"
  version="3.0">
  <!-- 2023-07-10 ebb: OLD ISSUE? Possibly unnecessary now: Do we really need to add a tei: prefixed namespace in addition to the default namespace?
    If we do, it may be to our output variorum edition files to support use of xml pointers in the Variorum edition, 
  so we are still adding it. It does not cause any harm. It means that we can refer to TEI elements as either `seg` or `tei:seg` when we write XSLT to match them in the
  source files. -->
  <!-- ebb: Run this with Saxon at command line to raise paired seg markers, using:
    java -jar saxon.jar -s:P5-Pt5-output/ -xsl:P5-Pt6spaceHandling.xsl -o:P5-Pt6-output/ 
    -->
  
  <xsl:mode on-no-match="shallow-copy"/>
  
  <xsl:variable name="P5-Pt5-coll" as="document-node()+" select="collection('P5-Pt5-output/?select=*.xml')"/> 
  
  <xsl:template match="/">
    <xsl:for-each select="$P5-Pt5-coll//TEI">
      <xsl:variable name="currentP5File" as="element()" select="current()"/>
      <xsl:variable name="filename" as="xs:string" select="tokenize(base-uri(), '/')[last()] ! replace(., 'Pt5', 'Pt6')"/>
      <xsl:variable name="chunk" as="xs:string" select="tokenize(base-uri(), '/')[last()] ! substring-before(., '.') ! substring-after(., '_')"/> 

      <xsl:result-document method="xml" indent="yes" href="P5-Pt6-output/{$filename}">
        <xsl:processing-instruction name="xml-model">href="../segMarkerTester.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
        <TEI xmlns="http://www.tei-c.org/ns/1.0"                 xmlns:pitt="https://github.com/ebeshero/Pittsburgh_Frankenstein" xmlns:mith="http://mith.umd.edu/sc/ns1#"  xmlns:th="http://www.blackmesatech.com/2017/nss/trojan-horse">
          <xsl:copy-of select="descendant::teiHeader" copy-namespaces="no"/>
          <text>
            <body>  
              <xsl:apply-templates select="descendant::div[@type='collation']">
              </xsl:apply-templates>
            </body>
          </text>
        </TEI>
      </xsl:result-document>
    </xsl:for-each>      
  </xsl:template>
  
  <xsl:template match="*[child::seg]//text()">
     <xsl:choose>
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
