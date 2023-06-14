<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:th="http://www.blackmesatech.com/2017/nss/trojan-horse"
    xmlns:mith="http://mith.umd.edu/sc/ns1#"
    xmlns:pitt="https://github.com/ebeshero/Pittsburgh_Frankenstein"
    xmlns:var="https://frankensteinvariorum.github.io"
    exclude-result-prefixes="xs math var"
    version="3.0">
    
    <!-- 2023-06-1 ebb yxj nlh: This XSLT should output separate chapter files. It is not doing that yet. 
    We have only tried it for the fMS so far, and it is outputting only one file, named with the correct text node, but otherwise systematically excluding its content. AND it is failing by only outputting a single file.
    
    ebb thinks we should proceed by testing the OTHER print editions, and see if that helps us figure out the problem in fMS.
   
    -->
    <xsl:mode on-no-match="shallow-copy" exclude-result-prefixes="th mith pitt var"/>
  
    
    <xsl:variable name="wholeFiles" as="document-node()+" select="collection('P6-Pt2/?select=*.xml')"/>    
    
    <xsl:template match="/" exclude-result-prefixes="th mith pitt var">
        <xsl:for-each select="$wholeFiles">
            <xsl:variable name="currFile" as="document-node()" select="current()"/>
           
            <xsl:for-each-group select="$currFile//tei:anchor[@type='semantic']/following-sibling::node()" group-starting-with="tei:anchor[@type='semantic']">
  
          <xsl:choose>
              <xsl:when test="position() = 1">
                  <xsl:result-document
                      href="P6-Pt3/{$currFile//tei:anchor[@type='semantic'][1]/@xml:id}.xml"
                      method="xml" indent="yes"> 
                      <TEI>
                          <teiHeader>
                              <fileDesc>
                                  <titleStmt>
                                      <title>Bridge Phase 6: <xsl:value-of select="current()/@xml:id ! replace(., '_', ' ')"/></title>
                                  </titleStmt>
                                  <publicationStmt>
                                      <authority>Frankenstein Variorum Project</authority>
                                      <date>2023—</date>
                                      <availability>
                                          <licence>Distributed under a Creative Commons
                                              Attribution-ShareAlike 3.0 Unported License</licence>
                                      </availability>
                                  </publicationStmt>
                                  <sourceDesc>
                                      <p>Produced from a corpus of collation output files for the Frankenstein Variorum digital edition
                                          on <xsl:value-of select="current-dateTime()"/>.</p>
                                  </sourceDesc>
                              </fileDesc>
                          </teiHeader>
                          <text>
                              <body>
                                  <xsl:copy select="$currFile//tei:anchor[@type='semantic'][1]" copy-namespaces="no">
                                      <xsl:copy-of select="@*"/>
                                  </xsl:copy>
                                  <xsl:apply-templates select="current-group()" exclude-result-prefixes="th mith pitt var"/>
                              </body>
                          </text>
                      </TEI>
                  </xsl:result-document>
                  
                  
              </xsl:when>
              <xsl:otherwise>
                      <xsl:result-document
                    href="P6-Pt3/{current()/@xml:id}.xml"
                    method="xml" indent="yes"> 
                    <TEI>
                        <teiHeader>
                            <fileDesc>
                                <titleStmt>
                                    <title>Bridge Phase 6: <xsl:value-of select="current()/@xml:id ! replace(., '_', ' ')"/></title>
                                </titleStmt>
                                <publicationStmt>
                                    <authority>Frankenstein Variorum Project</authority>
                                    <date>2023—</date>
                                    <availability>
                                        <licence>Distributed under a Creative Commons
                                            Attribution-ShareAlike 3.0 Unported License</licence>
                                    </availability>
                                </publicationStmt>
                                <sourceDesc>
                                    <p>Produced from a corpus of collation output files for the Frankenstein Variorum digital edition
                                        on <xsl:value-of select="current-dateTime()"/>.</p>
                                </sourceDesc>
                            </fileDesc>
                        </teiHeader>
                        <text>
                            <body>
                                <xsl:apply-templates select="current-group()" exclude-result-prefixes="th mith pitt var"/>
                            </body>
                        </text>
                    </TEI>
                </xsl:result-document></xsl:otherwise></xsl:choose>
            </xsl:for-each-group>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="tei:teiHeader"/>
        
    
</xsl:stylesheet>