<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xpath-default-namespace="http://www.tei-c.org/ns/1.0"  xmlns:pitt="https://github.com/ebeshero/Pittsburgh_Frankenstein"
    xmlns="http://www.tei-c.org/ns/1.0"  
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:mith="http://mith.umd.edu/sc/ns1#"
    xmlns:th="http://www.blackmesatech.com/2017/nss/trojan-horse"
    exclude-result-prefixes="xs" version="3.0">
    <!--2019-06-19 ebb: This is a patch which I hope will be temporary. When I redirected the pointers for S-GA files into the fv-data variorum-chunks directory, the locations where there's no data for the fMS (where it's missing, from C01 - C06 and the first parts of C07, and later C19), we are nevetheless generating pointers (into nonexistent files). This XSLT finds those empty locations for fMS and removes the output pointers, to just produce an empty <rdg wit="#fMS"/> as we did before. We're taking input from the standoff_Spine directory in fv-postCollation, and outputting to the standoff_Spine directory in fv-data. --> 
  <xsl:mode on-no-match="shallow-copy"/>
    <xsl:variable name="spineColl" as="document-node()+" select="collection('standoff_Spine/?select=*.xml')"/>
 <xsl:template match="/">
   <xsl:for-each select="$spineColl">
       <xsl:variable name="filename" as="xs:string" select="base-uri() ! tokenize(., '/')[last()]"/>
     <xsl:result-document method="xml" indent="yes" href="../../fv-data/standoff_Spine/{$filename}">
         <xsl:apply-templates/>
     </xsl:result-document>    
   </xsl:for-each>  
 </xsl:template>  
    <xsl:variable name="emptyString" as="xs:string" select="'[&#39;&#39;]'"/>
    <xsl:template match="rdgGrp[string-length(@n) le 4][count(descendant::rdg) eq 1]/rdg[@wit='#fMS']">
        <xsl:copy select=".">
            <xsl:copy select="@*"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>


