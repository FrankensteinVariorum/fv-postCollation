<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xpath-default-namespace="http://www.tei-c.org/ns/1.0"  xmlns:pitt="https://github.com/ebeshero/Pittsburgh_Frankenstein"
xmlns:mith="http://mith.umd.edu/sc/ns1#"  xmlns:th="http://www.blackmesatech.com/2017/nss/trojan-horse"
    xmlns="http://www.tei-c.org/ns/1.0"  
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="3.0">

<xsl:mode on-no-match="shallow-copy"/>
    <xsl:variable name="preP5a-coll" as="document-node()+" select="collection('preP5a-output/?select=*.xml')"/> 
<!--2018-10-10 ebb: This XSLT plants seg part start and end markers at uneven levels of the hierarchy. 
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
    <xsl:template match="text()[preceding-sibling::seg[1][@part and @th:sID][not(@th:sID = following-sibling::seg[@part]/@th:eID)]][following-sibling::node()[1][seg/substring-before(@th:eID, '__') = preceding-sibling::seg[1][@part and @th:sID]/substring-before(@th:sID, '__')]]">
        <xsl:copy-of select="current()" copy-namespaces="no"/>
        <seg th:eID="{preceding-sibling::seg[1][@part and @th:sID]/@th:sID}" part="{preceding-sibling::seg[1][@part and @th:sID]/@part}"/> 
    </xsl:template>
   
    <xsl:template match="text()[following-sibling::seg[1][@part and @th:eID][not(@th:eID = preceding-sibling::seg[1][@part]/@th:sID)]][preceding-sibling::node()[1]/seg[last()][substring-before(@th:eID, '__') = following::seg[1][@part and @th:eID]/substring-before(@th:eID, '__')]][1]">
        <seg th:sID="{following-sibling::seg[1][@part and @th:eID]/@th:eID}" part="{following-sibling::seg[1][@part and @th:eID]/@part}"/>
        <xsl:copy-of select="current()" copy-namespaces="no"/>
   </xsl:template>
        
 
</xsl:stylesheet>
            
   


