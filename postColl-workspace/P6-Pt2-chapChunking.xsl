<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:th="http://www.blackmesatech.com/2017/nss/trojan-horse"
    xmlns:mith="http://mith.umd.edu/sc/ns1#"
    xmlns:pitt="https://github.com/ebeshero/Pittsburgh_Frankenstein"
    exclude-result-prefixes="xs math"
    version="3.0">
    
    <!-- 2023-06-1 ebb yxj nlh: This XSLT should output separate chapter files. It is not doing that yet. 
    We have only tried it for the fMS so far, and it is outputting only one file, named with the correct text node, but otherwise systematically excluding its content. AND it is failing by only outputting a single file.
    
    ebb thinks we should proceed by testing the OTHER print editions, and see if that helps us figure out the problem in fMS.
   
    -->
    
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xsl:variable name="wholeFiles" as="document-node()+" select="collection('P6-Pt1/?select=*.xml')"/>    
    
    <xsl:template match="/">
        <xsl:for-each select="$wholeFiles">
            <xsl:variable name="currFile" as="document-node()" select="current()"/>

            <xsl:choose>
                <xsl:when test="$currFile ! base-uri()[contains(., 'fMS')]">
                    <xsl:for-each-group select="$currFile//tei:div[@type='collation']" group-starting-with="tei:milestone[@unit='tei:head']">
                        
                   
                        <xsl:variable name="file_id" as="xs:string" select="following::text()[not(matches(., '^\s+$'))][1] ! lower-case(.) ! tokenize(., ' ')[position() gt 1 and not(position() = last())] => string-join('_') 
                            || '_' || count(preceding::tei:milestone[@unit='tei:head'])"/>
                        
                       
                           <xsl:result-document href="P6-Pt2/fMS_{$file_id}.xml" method="xml" indent="yes">
                            
                            
                           <TEI> 
                               <teiHeader>
                                   <titleSmt><title><xsl:value-of select="$file_id"/></title></titleSmt>
                               </teiHeader>
                               <text>
                              <body> 
                                  <xsl:apply-templates select="current-group()"/>
                              </body>
                               </text>
                           </TEI>
                            <!--
                                href="collationChunks-simple/{base-uri() ! tokenize(., '/')[last()] ! substring-before(., '.')}_{current()/@xml:id}.xml"
                method="xml" indent="yes"
                                
                                
                                output filenames should look like this: 
                            
                            fMS_chapter_twenty-three
                            
 $msCollection//milestone[@unit='tei:head'][following::text()[not(matches(., '^\s+$'))][1]] ! lower-case(.) ! tokenize(., ' ') => string-join('_')
                            -->
                            
                            
                        </xsl:result-document>
                        
                    </xsl:for-each-group>
                    
                    
                </xsl:when>
                
                <xsl:otherwise>
                    <xsl:for-each-group select="$currFile//milestone[@unit='chapter' and @type='start']/following-sibling::node()" group-starting-with="milestone[@unit='chapter' and @type='start']">
                        
                        <xsl:message>I AM PROCESSING A PRINT EDITION FILE!</xsl:message>
                     <!--   <xsl:result-document href="P6-Pt2/{}" method="xml" indent="yes">
                            -->
                            <!--output filenames should look like this: 
                            
                            f1818_vol_i_chapter_iii
                            -->
                            
                            
                            
                        <!--</xsl:result-document>-->
                   </xsl:for-each-group>
            </xsl:otherwise>
            </xsl:choose>
            
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="teiHeader"/>
        
        
    
    
    

    
</xsl:stylesheet>