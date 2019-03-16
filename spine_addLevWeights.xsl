<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
xmlns:tei="http://www.tei-c.org/ns/1.0"  xmlns:pitt="https://github.com/ebeshero/Pittsburgh_Frankenstein"
    xmlns="http://www.tei-c.org/ns/1.0"  
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:mith="http://mith.umd.edu/sc/ns1#"
    xmlns:th="http://www.blackmesatech.com/2017/nss/trojan-horse"
    exclude-result-prefixes="xs tei" version="3.0">
    <!--2018-10-24 updated 2019-03-16 ebb: This stylesheet maps the maximum Levenshtein distance value for each app onto the spine files. Note: We may or may not wish to run the LevWeight-Simplification.xsl beforehand (which would remove comparisons with "0" at gap or cut locations where one or more witnesses are not present). My current thinking is that we should *not* run this because omissions are an important source of variance.  -->
  <xsl:mode on-no-match="shallow-copy"/>
    <xsl:variable name="spineColl" as="document-node()+" select="collection('preLev_standoff_Spine/?select=*.xml')"/>
    <xsl:variable name="FS_Levs" as="document-node()" select="doc('edit-distance/FV_LevDists-weighted.xml')"/>
   
<xsl:template match="/">
    <xsl:for-each select="$spineColl//tei:TEI">
        <xsl:variable name="filename" as="xs:string" select="tokenize(current()/base-uri(), '/')[last()]"/>
        <xsl:result-document method="xml" indent="yes" href="standoff_Spine/{$filename}"> 
            <TEI>
          <xsl:apply-templates/>
            </TEI>
        </xsl:result-document>
    </xsl:for-each>
</xsl:template>
    <xsl:template match="tei:app">
        <app xml:id="{@xml:id}" n="{$FS_Levs//fs[@feats=current()/@xml:id]/f/@fVal => max()}">
       <xsl:apply-templates/>     
            
        </app>
        
    </xsl:template>
           
</xsl:stylesheet>