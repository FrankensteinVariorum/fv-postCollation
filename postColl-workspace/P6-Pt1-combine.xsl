<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:th="http://www.blackmesatech.com/2017/nss/trojan-horse" exclude-result-prefixes="xs th"
  version="3.0">
  <!--2023-06-13 ebb: Like the immediately previous pipeline stages, this requires add a tei: prefixed namespace in addition to the default namesapce to our output variorum edition files 
    to support use of xml pointers in the Variorum edition. -->
  
  <xsl:mode on-no-match="shallow-copy"/>
  
  <xsl:variable name="P5-coll" as="document-node()+" select="collection('P5-Pt6-output/?select=*.xml')"/> 
  <xsl:variable name="editionNames" as="xs:string+" select="('f1818', 'f1823', 'fThomas', 'f1831', 'fMS')"/> 
  
  <xsl:template match="/">
    <xsl:for-each select="$editionNames">
      <xsl:variable name="currentEdition" as="xs:string" select="current()"/>
      <xsl:result-document method="xml" indent="yes" href="P6-Pt1-output/{$currentEdition}.xml">
        <teiCorpus>
        <xsl:for-each select="$P5-coll[contains(base-uri(), $currentEdition)]">
          <xsl:sort select="//text//anchor[@type='collate']/@xml:id"/>
          <xsl:apply-templates/>
        </xsl:for-each>
        </teiCorpus>
      </xsl:result-document>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
