<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:cx="http://interedition.eu/collatex/ns/1.0"
    exclude-result-prefixes="xs"
    version="3.0">
    <xsl:output method="xhtml" encoding="utf-8" doctype-system="about:legacy-compat"
        omit-xml-declaration="yes"/>
<xsl:variable name="P1coll" as="document-node()+" select="collection('P1-output/')"/>
    <xsl:variable name="unreadyColl" as="document-node()+" select="collection('unready-collated-data/?select=*.xml')"/>
  <xsl:template match="/">
      <html>
          <head>
              <title>Frankenstein Variorum Collation Data</title>
              <link rel="stylesheet" type="text/css" href="tableView.css"/>
          </head>
          <body>
       <h1>Frankenstein Variorum Collation Data</h1>
   <p>This is a view of aligned passages from machine-assisted and corrected collation of the five editions comprising the Frankenstein Variorum.</p>
                <div id="ready"> <xsl:apply-templates select="$P1coll//app">
                     <xsl:sort select="ancestor::TEI/@xml:id"/> 
                 </xsl:apply-templates>
                </div>
              <div id="unready">
                  <xsl:apply-templates select="$unreadyColl//cx:app">
                      <xsl:sort select="base-uri() ! tokenize(., '/')[last()] ! substring-after(., '_') ! substring-before(., '.')"/>
                  </xsl:apply-templates>
              </div>
          </body>
      </html>
  </xsl:template>
    <xsl:template match="app">
       <xsl:choose><xsl:when test="count(rdgGrp) gt 1"> <section id="{@xml:id}" class="multiRG">
            <h3><xsl:apply-templates select="@xml:id"/></h3>
            <xsl:apply-templates select="rdgGrp"/>
            </section></xsl:when>
       <xsl:otherwise>
           <section id="{@xml:id}" class="uniRG">
               <h3><xsl:apply-templates select="@xml:id"/></h3>
               <xsl:apply-templates select="rdgGrp"/>
           </section>
       </xsl:otherwise>
       </xsl:choose>
    </xsl:template>
    <xsl:template match="rdgGrp">
        <xsl:choose><xsl:when test="parent::app/rdgGrp => count() gt 1">
            <h4>Reading Group: <xsl:apply-templates select="@xml:id"/></h4>
           <table id="{@xml:id}" class="multiRG"><xsl:apply-templates select="rdg"/></table>
        </xsl:when>
            <xsl:otherwise>
            <h4>Unified Readings</h4>    
               <table><xsl:apply-templates select="rdg"/></table>
                
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    <!--Templates to match on ready collated data in TEI. -->
    <xsl:template match="rdg">
       <tr class="{@wit}"> <td class="wit">Witness: <xsl:apply-templates select="@wit"/></td>
        <td class="passage"><xsl:apply-templates/></td>
       </tr>
    </xsl:template>
    <xsl:template match="text()">
        <xsl:analyze-string select="." regex="&lt;del.+?sID.+?/&gt;(.+?)&lt;del.+?eID.+?/&gt;">
            <xsl:matching-substring>
                <span class="del">
                    <xsl:apply-templates select="regex-group(1)"/>
                </span>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
           <xsl:analyze-string select="." regex="&lt;mdel&gt;(.+?)&lt;/mdel&gt;">
             <xsl:matching-substring>  
                 <span class="del">
                   <xsl:apply-templates select="regex-group(1)"/>
               </span>
             </xsl:matching-substring>
               <xsl:non-matching-substring>
                 <xsl:analyze-string select="." regex="&lt;[lp]b.+?/&gt;">
                     <xsl:matching-substring/>
                     <xsl:non-matching-substring>
                      <xsl:analyze-string select="." regex="(&lt;\w+?)\s[se]ID.+?(/&gt;)"><xsl:matching-substring>
         <xsl:apply-templates select="regex-group(1)"/><xsl:apply-templates select="regex-group(2)"/>                 
                      </xsl:matching-substring>
     <xsl:non-matching-substring>
         <xsl:analyze-string select="." regex="&lt;milestone.+?/&gt;">
             <xsl:matching-substring/>
             <xsl:non-matching-substring>
                 <xsl:apply-templates select="."/>
             </xsl:non-matching-substring>
         </xsl:analyze-string>
     </xsl:non-matching-substring>          
                      </xsl:analyze-string>  </xsl:non-matching-substring>
                 </xsl:analyze-string>
               </xsl:non-matching-substring>
           </xsl:analyze-string>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
       
    </xsl:template>
    <!--Templates to match on UNREADY collection -->
    
</xsl:stylesheet>