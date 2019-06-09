<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xpath-default-namespace="http://www.tei-c.org/ns/1.0"  xmlns:pitt="https://github.com/ebeshero/Pittsburgh_Frankenstein"
    xmlns="http://www.tei-c.org/ns/1.0"  
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:mith="http://mith.umd.edu/sc/ns1#"
    xmlns:th="http://www.blackmesatech.com/2017/nss/trojan-horse"
    exclude-result-prefixes="xs" version="3.0">

  <xsl:mode on-no-match="shallow-copy"/>
    <xsl:strip-space elements="*"/>
    <xsl:variable name="P3-Coll" as="document-node()+" select="collection('P3-output/?select=*.xml')"/>
<!--2018-10-10 ebb: For stage 3.5 we need to reconstruct full collation chunks that have been subdivided into parts. For example, C08 was divided into parts C08a through C08j, often breaking up element tag pairs. Here we reunite the pieces so we can move on to up-raising the flattened elements in the editions. -->   
   <xsl:template match="/">
       <xsl:for-each-group select="$P3-Coll" group-by="tokenize(base-uri(), '-f')[last()] ! tokenize(., '[a-z]?\.xml')[1]">
           <xsl:variable name="filename" select="concat('P3-f', current-grouping-key(), '.xml')"/>  
           <xsl:variable name="witness" select="tokenize($filename, '-')[last()] ! substring-before(., '_')"/>
           <xsl:variable name="chunk" select="tokenize($filename, '_')[last()] ! substring-before(., '.xml')"/>
           <xsl:result-document method="xml" indent="yes" href="P3.5-output/{$filename}">
          <TEI>
              <teiHeader>
                  <fileDesc>
                      <titleStmt>
                          <title>Bridge Phase 3: Witness <xsl:value-of select="$witness"/>, Collation unit <xsl:value-of select="$chunk"/></title>
                      </titleStmt>
                      <publicationStmt>
                          <authority>Frankenstein Variorum Project</authority>
                          <date>2018</date>
                          <availability>
                              <licence>Distributed under a Creative Commons
                                  Attribution-ShareAlike 3.0 Unported License</licence>
                          </availability>
                      </publicationStmt>
                     <xsl:copy-of select="(current-group()//TEI/teiHeader//sourceDesc)[1]"/>
                  </fileDesc>
              </teiHeader>
          
         <text>
             <body>
                 <div type="collation" xml:id="{tokenize(descendant::div/@xml:id, '[a-z]')[1]}">
                     <xsl:for-each select="current-group()//TEI">
                         <xsl:sort select="base-uri()"/>
                         <xsl:apply-templates select="descendant::div[@type='collation']"/>
                     </xsl:for-each>
                 </div>
             </body>
         </text>
              
          </TEI>    
               
               
           </xsl:result-document> 
       </xsl:for-each-group>
   </xsl:template>
    <xsl:template match="div[@type='collation']">
        <xsl:apply-templates/>
    </xsl:template>
           
</xsl:stylesheet>


