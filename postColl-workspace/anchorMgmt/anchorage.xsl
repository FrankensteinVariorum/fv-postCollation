<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xpath-default-namespace="http://www.tei-c.org/ns/1.0"  xmlns:pitt="https://github.com/ebeshero/Pittsburgh_Frankenstein"
    xmlns="http://www.tei-c.org/ns/1.0"  
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:mith="http://mith.umd.edu/sc/ns1#"
    xmlns:th="http://www.blackmesatech.com/2017/nss/trojan-horse"
    exclude-result-prefixes="xs" version="3.0">

<!-- 2019-06-26 ebb: This XSLT is designed add data about left margin zones from S-GA edition files to our P1 files. Our ultimate goal is to generate more specific data from the @corresp on left margin locations to hold in our spine pointers. 
    1) Determine when a left margin location is by itself in an rdg (without data from a main surface zone). This will simply need the @corresp attribute data.
    2) Determine when a left margin location is preceded by or followed by a main surface location in an rdg: These cases require an output anchor element to serve as a signal post, holding the @xml:id that points to the corresponding left_margin zone's @corresp. 
    3) For output string pointers, we probably want a representation of this data in text form as flattened elements. Or do we just want to plant self-closing anchor elements, and draw from them as needed? 
    -->
  <xsl:mode on-no-match="shallow-copy"/>
    <xsl:variable name="P1-Coll" as="document-node()+" select="collection('../P1-output/?select=*.xml')"/>
<xsl:variable name="sga-mscoll" as="document-node()+" select="collection('ms-variorum-chunks')"/>
   <xsl:template match="/">
       <xsl:for-each select="$P1-Coll//TEI[base-uri() ! tokenize(., '/')[last()] ! substring-before(., '.xml') !
           substring-after(., '_C') ! replace(., '[a-z]$', '') ! number() ge 7]">
           <xsl:variable name="currentP1File" as="element()" select="current()"/>
           <xsl:variable name="filename">
              <xsl:value-of select="tokenize(base-uri(), '/')[last()]"/>
           </xsl:variable>
         <xsl:variable name="chunk" as="xs:string" select="substring-after(@xml:id, '-')"/>          
           <xsl:result-document method="xml" indent="yes" href="P1-anchorOut/{$filename}">
               <TEI>
                   <xsl:message>Which file am I processing? 
                   <xsl:value-of select="tokenize(base-uri(), '/')[last()]"/>. Value of $chunk is: <xsl:value-of select="$chunk"/>.
                   </xsl:message>
           <xsl:apply-templates/>
               </TEI>
           </xsl:result-document>
       </xsl:for-each>    
   </xsl:template> 
<!--This template matches on MS rdg elements that hold a combination of main and left margin data. Re the margin data, the main data could precede or follow (or both).
    Conditions to look for:
    Is there an lb in main at this location? (Y or N)
    Look for signals of the left margin location on add or del elements: 
    Q: Is this one? c56-0012.02
    A: Not always! sometimes these are superlinear insertions/modifications. Only sometimes are they pointing to left margin zones. But when we find the pattern on an lb designated as inside a left_margin, we know there will be an anchor in the main text to match it, and we can find it in the S-GA file.
    When we find it, we will want to place the anchor element at the moment JUST BEFORE the first lb in the left margin zone in our P1 file.
    -->  
    <xsl:template match="rdg[@wit='fMS'][contains(., '__left_margin')][contains(., '__main')]">
        <xsl:analyze-string select="." regex="&lt;[^/&amp;]+?&gt;">
            <!--a start tag or a self-closing element, containing data we need-->
            <xsl:matching-substring>
                
            </xsl:matching-substring>
        </xsl:analyze-string> 
    </xsl:template>
    
<!-- ebb: Some old reference code from P2 XSLT on using xsl:analyze-string
        <xsl:template match="ab/text()">
        <xsl:analyze-string select="." regex="&lt;[^/&amp;]+?&gt;"><!-\-a start tag of an unflattened element (left as a whole element prior to collation).-\->
            <xsl:matching-substring>
                <xsl:variable name="tagContents" select="substring-after(., '&lt;') ! substring-before(., '&gt;')"/>
                <xsl:element name="{tokenize($tagContents, ' ')[1]}">
                    <xsl:attribute name="ana">
                        <xsl:text>start</xsl:text>
                    </xsl:attribute>
                    <xsl:for-each select="tokenize($tagContents, ' ')[position() gt 1][contains(., '=')]">
                        <xsl:attribute name="{substring-before(current(), '=')}">
                            <xsl:value-of select="substring-after(current(), '=&#34;') ! substring-before(., '&#34;') "/>
                        </xsl:attribute>
                    </xsl:for-each>
                </xsl:element>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:analyze-string select="." regex="&lt;/[^/&amp;]+?&gt;"><!-\-an end tag of an unflattened element-\->
                    <xsl:matching-substring>
                        <xsl:variable name="tagContents" select="substring-after(., '&lt;/') ! substring-before(., '&gt;')"/>
                        <xsl:element name="{tokenize($tagContents, ' ')[1]}">
                            <xsl:attribute name="ana">
                                <xsl:text>end</xsl:text>
                            </xsl:attribute>
                            
                        </xsl:element>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:analyze-string select="." regex="&lt;.[^/]+?[es]ID=[^/]+?/&gt;">
   <!-\-matches strings representing flattened element tags marked with sID and eID attributes. -\->                         <xsl:matching-substring>
                                <xsl:variable name="flattenedTagContents" select="substring-before(., '/') ! substring-after(., '&lt;')"/>
                                <xsl:variable name="elementName" select="tokenize($flattenedTagContents, ' ')[1]"/>
                                <xsl:message>Flattened Tag Contents:  <xsl:value-of select="$flattenedTagContents"/></xsl:message>
                                
                                <xsl:element name="{$elementName}">
                                    <xsl:for-each select="tokenize($flattenedTagContents, ' ')[position() gt 1][contains(., '=')]">
                                        <xsl:variable name="attName" as="xs:string">
       <xsl:choose>
           <xsl:when test="matches(current(), '[se]ID')">
               <xsl:value-of select="concat('th:', substring-before(current(), '='))"/>
           </xsl:when>
           <xsl:otherwise>
               <xsl:value-of select="substring-before(current(), '=')"/>   
           </xsl:otherwise>
       </xsl:choose>                                   
</xsl:variable>
                                        <xsl:attribute name="{$attName}">
                                            <xsl:value-of select="substring-after(current(), '=&#34;') ! substring-before(., '&#34;')"/>    
                                        </xsl:attribute>
                                    </xsl:for-each> 
                                </xsl:element>
                            </xsl:matching-substring>
                            <xsl:non-matching-substring>
                                <xsl:analyze-string select="." regex="&lt;[^/]*\n*[^/]+?/&gt;">
                                 <!-\-matches text strings representing self-closed elements (the milestone elements and such like). -\->                              <xsl:matching-substring>
                                     <xsl:variable name="flattenedTagContents" select="substring-after(., '&lt;') ! substring-before(., '/&gt;')"/>
                                       
                                        <xsl:variable name="elementName" select="tokenize($flattenedTagContents, '\s+')[1]"/>
                                        <xsl:element name="{$elementName}">
                                            <xsl:variable name="attributeString" select="string-join(tokenize($flattenedTagContents, '\s+')[position() gt 1], ' ')"/>
                                          
                                            <xsl:for-each select="tokenize($attributeString, '\s+')">
                                                <xsl:variable name="attributeStringToken" select="current()"/>
                                                <xsl:variable name="attName" select="substring-before(current(), '=&#34;')"/>
                                                <xsl:variable name="attValue" select="substring-after(current(), '=')"/> 
                                                <xsl:attribute name="{$attName}">
                                                    <xsl:value-of select="substring-after($attValue, '&#34;') ! substring-before(., '&#34;')"/>
                                                </xsl:attribute>
                                            </xsl:for-each>         
                                        </xsl:element> 
                                        
                                    </xsl:matching-substring>
                                    <xsl:non-matching-substring>
                                        <xsl:value-of select="."/>
                                    </xsl:non-matching-substring> 
        </xsl:analyze-string>                           
       </xsl:non-matching-substring>
      </xsl:analyze-string>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
   </xsl:template>-->
           
</xsl:stylesheet>


