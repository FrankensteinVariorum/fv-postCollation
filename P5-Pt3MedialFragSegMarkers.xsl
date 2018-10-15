<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xpath-default-namespace="http://www.tei-c.org/ns/1.0"  xmlns:pitt="https://github.com/ebeshero/Pittsburgh_Frankenstein"
xmlns:mith="http://mith.umd.edu/sc/ns1#"  xmlns:th="http://www.blackmesatech.com/2017/nss/trojan-horse"
    xmlns="http://www.tei-c.org/ns/1.0"  
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="3.0">

<xsl:mode on-no-match="shallow-copy"/>
    <xsl:variable name="preP5a-coll" as="document-node()+" select="collection('preP5a-output/?select=*.xml')"/> 
<!--2018-10-15 ebb: This XSLT plants medial seg markers to surround multiple element nodes in between fragmented seg start-pairs and end-pairs  
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
                
                <xsl:apply-templates select="descendant::div[@type='collation']">
                   
                </xsl:apply-templates>
            </body>
        </text>
        </TEI>
         </xsl:result-document>
       </xsl:for-each>      
   </xsl:template>
    <!--Setting MEDIAL marker pairs. THESE MUST SURROUND INTERVENING ELEMENT NODES IN BETWEEN START PAIRS AND END PAIRS. 
        Find where there is an element following a first preceding start-pair (seg part="I" and @eID). See if it has one or more elements on the following-sibling axis that precede a following end-pair (seg part="F" and @sID). These intermediary elements would not themselves contain segs.  
       -->
 
</xsl:stylesheet>
            
   


