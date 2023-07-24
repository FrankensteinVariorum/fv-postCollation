<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:var="https://frankensteinvariorum.github.io"
    exclude-result-prefixes="xs math"
    version="3.0">
    
 <!-- Take P6-P2 fThomas as input. We output a list of note elements to which 
we add URL information for the Huntington Library by hand. We also output information about the 
location of these notes in the Thomas file.  -->   
    
 <xsl:output method="xml" indent="yes"/>    
    <xsl:template match="/">
        <TEI>
            <xsl:copy-of select="teiHeader"/>
        
        
       <list>
        <xsl:apply-templates select="descendant::note[@ana='start']"/>
        
       </list> 
        
        </TEI>
        
    </xsl:template>
    
    <xsl:template match="note">
        <xsl:element name="{name()}">
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="source">
                <xsl:text>PLACEHOLDER</xsl:text>
            </xsl:attribute>
            
            <xsl:attribute name="ana">
                <xsl:choose>
                    <xsl:when test="ancestor::p">
                        <xsl:text>ancestor::p[@xml:id="</xsl:text>
                        <xsl:value-of select="ancestor::p/@xml:id ! normalize-space()"/>
                        <xsl:text>"]</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>ancestor::</xsl:text>
                        <xsl:value-of select="preceding::*[not(name(.) = 'seg')][1] ! name()"/>
                        <xsl:text>[1][@xml:id="</xsl:text>
                        <xsl:value-of select="preceding::*[not(name(.) = 'seg')][1]/@xml:id ! normalize-space()"/>
                        <xsl:text>"]</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                
                
            </xsl:attribute> 
            <xsl:copy select="following-sibling::text()[1]"/>
            
            
        </xsl:element>
        
        
    </xsl:template>
    
 
    
</xsl:stylesheet>