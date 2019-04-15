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
    <xsl:variable name="unreadyColl" as="document-node()+" select="collection('unready-TEI/?select=*.xml')"/>
  <xsl:template match="/">
      <html>
          <head>
              <title>Frankenstein Variorum Collation Data</title>
              <link rel="stylesheet" type="text/css" href="tableView.css"/>
          </head>
          <body>
      <div id="intro"> <h1>Frankenstein Variorum Collation Data</h1>
   <p>This is a view of aligned passages from machine-assisted and corrected collation of the five editions comprising the Frankenstein Variorum, and represents an incomplete work in progress on the variorum edition.</p>
   <p>Currently, as of April 2019, the collation output viewable here is incomplete, in two ways: </p>
 <ol>
     <li>It is missing the ending of the novel, because it represents collation units 01 to 26, out of 33 total units. (This is because the last 7 collation units have not yet been batched processed in collateX.)</li>
     <li>It represents portions of the collation output that have not yet been thoroughly hand-corrected, from C11 onward. There are occasional gaps for some editions when I have reserved passages to withhold from automated collation. Such gaps almost certainly represent major, serious differences of some editions from the others that need to be carefully woven back into the collation files, and we need to complete that work. 
     </li>
 </ol>
          <p>For more detail on the unready collation data, and for instructions on how to locate reserved passages that do not appear on this webpage, please see <a href="https://github.com/PghFrankenstein/fv-postCollation/blob/master/postColl-workspace/unready-collated-data/README.md">the ReadMe file on the Unready Collated Data directory</a> in our <a href="https://github.com/PghFrankenstein/fv-postCollation">GitHub fv-postCollation repository</a>.</p>
    <h3>Legend</h3>
              <p>We are using color-coding to distinguish between corrected and uncorrected collation data represented in this file. We also use color coding of table backgrounds to highlight aligned passages that represent variation across the five versions of the novel in our variorum.</p>
     <table class="legend">
        <tr><th>Correction status</th>
            <th>Page Background</th>
            <th>Variant passages</th></tr>
         <tr class="ready"><td>Ready</td>
             <td>------</td>
             <td class="multiRG">------</td>
         </tr>
         <tr class="unready"><td>Unready</td>
         <td>------</td>
         <td class="multiRG">------</td>
         </tr>
     </table>
         <!-- <xsl:variable name="rightSearchGlass" select="&#x1F50E;"/>-->
          <h3><xsl:text>&#x1F50E;</xsl:text> Instructions for searching</h3>
          <p>To search this document, use your web browser’s native <q>Find on this page</q> tools, using CTRL + F on a PC, or Command + F on a Mac.</p>
 
      </div>
              
                <div class="ready"> <xsl:apply-templates select="$P1coll//app">
                     <xsl:sort select="ancestor::TEI/@xml:id"/> 
                 </xsl:apply-templates>
                </div>
              <div class="unready">
                  <xsl:apply-templates select="$unreadyColl//app">
                      <xsl:sort select="ancestor::TEI/@xml:id"/>
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
</xsl:stylesheet>