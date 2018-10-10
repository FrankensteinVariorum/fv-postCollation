<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:pitt="https://github.com/ebeshero/Pittsburgh_Frankenstein"
    xmlns="http://www.tei-c.org/ns/1.0"    xmlns:xs="http://www.w3.org/2001/XMLSchema"   
    exclude-result-prefixes="xs"
    version="3.0">
<!--2018-10-10 ebb: Updating this to process current files that DO have meaningful rdgGrp elements. -->
<!--2018-06-21 ebb updated 2018-08-01: Bridge Edition Constructor Part 2: This second phase begins building the output Bridge editions by consuming the <app> and and <rdg> elements to replace them with <seg> elements that hold the identifiers of their apps and indication of whether they are portions.
   This stylesheet does NOT YET generate the spine file. We're deferring that to a later stage when we know where the <seg> elements turn up in relation to the hierarchy of the edition elements. 
   We are now generating the spine file following the edition files constructed in bridge P5, so that we have the benefit of seeing the <seg> elements where they need to be multiplied (e.g. around paragraph breaks). We can then generate pointers to more precise locations.   
    -->
<xsl:output method="xml" indent="yes"/>  

    <xsl:variable name="P1Files" as="document-node()+" select="collection('P1-output')"/>
    <xsl:variable name="witnesses" as="xs:string+" select="distinct-values($P1Files//@wit)"/>
    
   <xsl:template match="/">
       <xsl:for-each select="$P1Files//TEI"> 
           <xsl:variable name="currentP1File" as="element()" select="current()"/>
           <xsl:variable name="chunk" as="xs:string" select="substring-after(substring-before(tokenize(base-uri(), '/')[last()], '.'), '_')"/>          
  <!-- DEFER TO LATER STAGE AFTER P5: <xsl:result-document method="xml" indent="yes" href="standoff_Spine/spine_{$chunk}.xml">
               <TEI xml:id="spine-{$chunk}">
                   <teiHeader>
                       <fileDesc>
                           <titleStmt>
                               <title>Standoff Spine: Collation unit <xsl:value-of select="$chunk"/></title>
                           </titleStmt>
                           <xsl:copy-of select="descendant::publicationStmt"/>
                           <xsl:copy-of select="descendant::sourceDesc"/>
                       </fileDesc>
                   </teiHeader>
                   <text>
                       <body> 
                           <ab type="alignmentChunk" xml:id="spine_{$chunk}">
                               <xsl:apply-templates  select="descendant::app" mode="spinePtrs">
                                   <xsl:with-param name="chunk" select="$chunk" tunnel="yes"></xsl:with-param>
                               </xsl:apply-templates>
                               
                           </ab>
                       </body>
                       
                   </text>
               </TEI> 
           </xsl:result-document>-->
       
           
         <xsl:for-each select="$witnesses">

             <xsl:result-document method="xml" indent="yes" href="P2-output/P2_{current()}_{$chunk}.xml">
                 <TEI xml:id="{current()}_{$chunk}">
            <teiHeader>
                <fileDesc>
                    <titleStmt>
                        <title>Bridge Phase 2: Witness <xsl:value-of select="current()"/>, Collation unit <xsl:value-of select="$chunk"/></title>
                    </titleStmt>
                    <xsl:copy-of select="$currentP1File//publicationStmt"/>
                    <xsl:copy-of select="$currentP1File//sourceDesc"/>
                </fileDesc>
            </teiHeader>
            <text>
           <body> 
        <ab type="alignmentChunk" xml:id="{$chunk}">
            <xsl:apply-templates  select="$currentP1File//app">
                <xsl:with-param name="currentWit" as="xs:string" select="current()" tunnel="yes"/>
            </xsl:apply-templates>
                
               </ab>
           </body>
                    
            </text>
        </TEI>
           </xsl:result-document>
         </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="app">
        <xsl:param name="currentWit" tunnel="yes"/>
        <xsl:choose>
            <xsl:when test="count(rdgGrp) eq 1 and count(descendant::rdg) = 5">
                <xsl:apply-templates select="descendant::rdg[@wit=$currentWit]" mode="invariant"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="descendant::rdg[@wit=$currentWit]" mode="variant"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="rdg" mode="invariant">
        <xsl:apply-templates select="."/>
    </xsl:template>
    <xsl:template match="rdg" mode="variant">
    <seg xml:id="{ancestor::app/@xml:id}-{@wit}_start"/>
            <xsl:apply-templates select="."/><seg xml:id="{ancestor::app/@xml:id}-{@wit}_end"/> 
    </xsl:template>
   <!-- <xsl:template match="rdg" mode="invariant-MissingWit">
        <xsl:param name="currentWit" tunnel="yes"/>
        <xsl:message>found a missing witness! but the others agree.</xsl:message>
        <xsl:if test=".[@wit=$currentWit]"><seg type="invariant-MissingWit" xml:id="{parent::app/@xml:id}-{substring-after($currentWit, '#')}_start"/><xsl:apply-templates select=".[@wit=$currentWit]"/><seg xml:id="{parent::app/@xml:id}-{substring-after($currentWit, '#')}_end"/></xsl:if>
    </xsl:template>
    <xsl:template match="app" mode="spinePtrs">
        <xsl:param name="rdgs" select="rdg" as="element()+" tunnel="yes"/>
        <xsl:param name="chunk" tunnel="yes"/>
        <xsl:choose><xsl:when test="@type"> <app type="{@type}" xml:id="{@xml:id}"><xsl:apply-templates mode="spinePtrs"/></app></xsl:when>
            <xsl:when test="contains(string(pitt:compareWits($rdgs)), 'true')">
                <rdgGrp type="invariant">
                   <xsl:apply-templates mode="spinePtrs"/> 
                </rdgGrp>
            </xsl:when>
            <xsl:otherwise>
                <app xml:id="{@xml:id}"><xsl:apply-templates select="rdg" mode="spinePtrs">
                    <xsl:with-param name="chunk" select="$chunk" tunnel="yes"></xsl:with-param>
                </xsl:apply-templates></app>
            </xsl:otherwise>
        </xsl:choose>
      </xsl:template>
    <xsl:template match="rdg" mode="spinePtrs">
        <xsl:param name="chunk" tunnel="yes"/>
        <rdg wit="{@wit}"><ref><ptr target="https://github.com/PghFrankenstein/Pittsburgh_Frankenstein/tree/Text_Processing/collateXPrep/bridge-P5/P5-{substring-after(@wit, '#')}_{$chunk}.xml#{parent::app/@xml:id}-{substring-after(@wit, '#')}"/>
            <pitt:line_text><xsl:value-of select="string-join(tokenize(., '&lt;[^/]+?/&gt;'))"/></pitt:line_text>
        <pitt:resolved_text>
            <!-\-2018-06-21 ebb: This particular destination doesn't exist quite yet, and will quite likely need to be modified. -\->
            <xsl:variable name="pointerFilePath"> <xsl:text>https://github.com/PghFrankenstein/Pittsburgh_Frankenstein/tree/Text_Processing/collateXPrep/bridge-P5/</xsl:text><xsl:value-of select="substring-after(@wit, '#')"/><xsl:text>_</xsl:text><xsl:value-of select="$chunk"/><xsl:text>.xml</xsl:text>
            </xsl:variable>
            <xsl:variable name="pointerHead">
                <xsl:text>P5-</xsl:text>
                <xsl:value-of select="substring-after(@wit, '#')"/>
                <xsl:text>_</xsl:text>
                <xsl:value-of select="$chunk"/>
                <xsl:text>.xml#</xsl:text>
                <xsl:value-of select="parent::app/@xml:id"/><xsl:text>-</xsl:text>
                <xsl:value-of select="substring-after(@wit, '#')"/>
            </xsl:variable>
            <xsl:variable name="testResolve" as="xs:string">
               <xsl:value-of select="$pointerFilePath//$pointerHead"/>
                <!-\-<xsl:choose> <xsl:when test="doc($pointerFilePath)//$pointerHead">
                   <xsl:text>The link resolves.</xsl:text>
                </xsl:when>
               <xsl:otherwise>
                   <xsl:text>The link doesn't resolve.</xsl:text>
               </xsl:otherwise>
               </xsl:choose>-\->
            </xsl:variable>
            <!-\-<xsl:variable name="pointedDoc" select="doc($pointerFilePath)" as="document-node()"/>-\->
         <!-\-   <xsl:evaluate xpath="doc($pointerFilePath)//$pointerHead"/>
            </xsl:variable> -\->
            <xsl:value-of select="$testResolve"/>
        </pitt:resolved_text>
        </ref>
        
        </rdg>
    </xsl:template>-->
    
</xsl:stylesheet>
