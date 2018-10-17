<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xpath-default-namespace="http://www.tei-c.org/ns/1.0"  xmlns:pitt="https://github.com/ebeshero/Pittsburgh_Frankenstein"
    xmlns="http://www.tei-c.org/ns/1.0"  
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:mith="http://mith.umd.edu/sc/ns1#" xmlns:th="http://www.blackmesatech.com/2017/nss/trojan-horse"
    exclude-result-prefixes="xs th pitt mith" version="3.0">

    <!--2018-10-17 ebb: Updated this to work on newly processed post-collation structure. Our new file structure gives us rdgGrps to start with, so we preserve these in our output.
        Run with saxon command line over P1-output directory and output to standoff_Spine directory, using:
        
   java -jar saxon9ee.jar -s:P1-output/ -xsl:P5_SpineGenerator.xsl -o:standoff_Spine/ 
    --> 
        <!--2018-07-30 updated 2018-08-01 ebb: This file is now designed to generate the first incarnation of the standoff spine of the Frankenstein Variorum. The spine contains URI pointers to specific locations marked by <seg> elements in the edition files made in bridge-P5, and is based on information from the collation process stored in TEI in bridge P1.
    -->
    <!--2018-07-30 rv: Fixed URLs to TEI files -->
    <!--2018-07-30 rv: Changing rdgGrps back into apps. This eventually should be addressed in previous steps. -->
    <xsl:mode on-no-match="shallow-copy"/>

    <xsl:variable name="P5_coll" as="document-node()+" select="collection('P5-output')"/>
    <xsl:template match="app[count(rdgGrp) gt 1]">
          <app>
          <xsl:copy-of select="@*"/>
          <xsl:variable name="appID" as="xs:string" select="@xml:id"/>
              <xsl:apply-templates select="rdgGrp"><xsl:with-param name="appID" as="xs:string" select="$appID"></xsl:with-param></xsl:apply-templates>
    </app>
    </xsl:template>
    <xsl:template match="rdgGrp">
        <xsl:param name="appID"/>
      <rdgGrp><xsl:copy-of select="@*"/>  
          <xsl:for-each select="rdg">
            <xsl:choose>
                <xsl:when test="@wit='#fMS'">
                    <xsl:sequence select="."/>
                </xsl:when>
                <xsl:otherwise>
                    <rdg wit="{@wit}">     <xsl:variable name="currWit" as="xs:string" select="@wit"/>
                        <xsl:variable name="currP1filename" as="xs:string" select="tokenize(base-uri(.), '/')[last()]"/>
                        <xsl:variable name="currEdition" as="element()*" select="$P5_coll//TEI[tokenize(base-uri(), '/')[last()] ! substring-before(., '_') ! substring-after(., 'P5-') eq $currWit][tokenize(base-uri(), '/')[last() ] ! substring-after(., '_') ! substring-before(., '.') = tokenize($currP1filename, '[a-z]?\.')[1] ! substring-after(., '_') ]"/>         
                        <xsl:variable name="currEd-Seg" as="element()*" select="$currEdition//seg[substring-before(@xml:id, '-') = $appID]"/>
                        <xsl:variable name="currEd-Chunk" as="xs:string" select="tokenize($currEdition/base-uri(), '/')[last()] ! substring-after(., '_') ! substring-before(., '.')"/> 
                        <xsl:message>Value of $currEd-Chunk is <xsl:value-of select="$currEd-Chunk"/></xsl:message>
                        <xsl:for-each select="$currEd-Seg">
                            <ptr target="https://raw.githubusercontent.com/PghFrankenstein/fv-data/master/edition-chunks/P5-{$currWit}_{$currEd-Chunk}.xml#{current()/@xml:id}"/>
                           <!-- ebb: Commenting out the pitt:line_text since we're reproducing its normalized tokens in the @n on rdgGrp 
       <pitt:line_text><xsl:value-of select="current()/normalize-space()"/></pitt:line_text>
                           --> 
                            <pitt:resolved_text><xsl:value-of select="concat('#', current()/@xml:id)"/></pitt:resolved_text>
                        </xsl:for-each>
                    </rdg>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>   
      </rdgGrp>
    </xsl:template>
    
<!--Suppresses invariant apps from the spine. -->
    <xsl:template match="app[count(rdgGrp) eq 1]"/>
    
<!--Uncomment if needed:
        <xsl:template match="ref"/>
    <xsl:template match="ptr"/>
    <xsl:template match="pitt:line_text"/>
    <xsl:template match="pitt:resolved_text"/>
    -->
</xsl:stylesheet>