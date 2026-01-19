<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xpath-default-namespace="http://www.tei-c.org/ns/1.0"    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="3.0">
    <xsl:output method="text" encoding="UTF-8"/>
    <xsl:variable name="spineColl" as="document-node()+" select="collection('../preLev_standoff_Spine/')"/>
    <xsl:template match="/">
        <!-- 2026-01-19 ebb: Renaming this file as the canonical extractCollationData.xsl for use in the pipeline, to faciliate output of the SVG heatmap.
        This XSLT should output data for variance in each reading group for measurement. This version of the XSLT should also output the witnesses present in
        each reading group. 
        -->
        <!--2018-10-21 updated 2019-03-16 ebb: This XSLT reads from the spine files as prepped through P5 of the postCollation pipeline, and it outputs a single tab-separated plain text file, named spineData.txt, with normalized data pulled from each rdgGrp (its @n attribute) in the spine files. The output file will need to be converted to ascii for weighted levenshtein calculations. 
        Use iconv in the shell (to change curly quotes and other special characters to ASCII format): For a single file:
        iconv -c -f UTF-8 -t ascii//TRANSLIT spineData-svgPrep.txt  > spineData-svgPrep-ascii.txt
        
        If batch processing a directory of output files to convert to ascii, use something like:
        for file in *.txt; do iconv -c -f UTF-8 -t ascii//TRANSLIT "$file" > ../spineDataASCII/"$file"; done
    (On using TRANSLIT with iconv, see https://unix.stackexchange.com/questions/171832/converting-a-utf-8-file-to-ascii-best-effort) 
        -->
        <xsl:result-document method="text" encoding="UTF-8" href="spineData-svgPrep.txt"> 
            <xsl:for-each select="$spineColl/TEI"> 
                <xsl:sort select="base-uri(.) ! tokenize(., '/')[last()]"/>
                <!-- <xsl:variable name="currentSpineFile" as="element()" select="current()"/>
           <xsl:variable name="filename" as="xs:string" select="$currentSpineFile/base-uri() ! tokenize(., '/')[last()] ! substring-before(., '.')"/>
           <xsl:result-document method="text" href="spineData/{$filename}.txt">-->
                <xsl:apply-templates select="descendant::app"/>
                <!--</xsl:result-document>-->
            </xsl:for-each></xsl:result-document>
    </xsl:template>
    
    
    <xsl:template match="app">
        <xsl:value-of select="@xml:id"/><xsl:text>&#x9;</xsl:text>
        <xsl:apply-templates select="rdgGrp"/>
        <!--This is to output blanks (or NoRG) so we always have 5 tab-separated values for the python script to compare for each possible rdgGrp. Blanks are encoded as a single white-space. -->
        <xsl:for-each select="(1 to (5 - count(rdgGrp)))">
            <xsl:text>NoRG&#x9; &#x9;</xsl:text>
        </xsl:for-each>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>
    <xsl:template match="rdgGrp">
        <!-- First output the rdgGrp xml:id -->
        <xsl:value-of select="@xml:id"/><xsl:text>::</xsl:text>
        <!-- Now, output the witnesses in the rdgGrp-->
        <xsl:value-of select="string-join(rdg/@wit, ' ')"/>
        <xsl:text>&#x9;</xsl:text>
        
        <!-- Next, output the normalized string of the rdg at this point -->
        <xsl:variable name="trimmed-nVal" as="xs:string">
            <xsl:choose>
                <xsl:when test="@n = ['']">
                    <xsl:text> </xsl:text>
                    <!--An empty rdgGrp is interpreted as a single white space.  -->
                </xsl:when>
                <xsl:otherwise><xsl:value-of select="substring-after(@n, '[') ! substring-before(., ']')"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="n-tokens" as="xs:string" select="tokenize($trimmed-nVal, ', ') ! translate(., '''', '') => string-join(' ')"/>
        <xsl:value-of select="$n-tokens"/>
        <xsl:text>&#x9;</xsl:text>
    </xsl:template>
    
    
</xsl:stylesheet>