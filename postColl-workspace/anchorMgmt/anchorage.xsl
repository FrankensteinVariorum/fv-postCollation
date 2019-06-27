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
    <xsl:variable name="sga-mscoll" as="document-node()+" select="collection('ms-variorum-chunks/?select=*.xml')"/>
   <xsl:template match="/">
       <xsl:for-each select="$P1-Coll//TEI[base-uri() ! tokenize(., '/')[last()] ! substring-before(., '.xml') !
           substring-after(., '_C') ! replace(., '[a-z]$', '') ! number() ge 7]">
           <xsl:variable name="currentP1File" as="element()" select="current()"/>
           <xsl:variable name="filename">
              <xsl:value-of select="concat('anch-', tokenize(base-uri(), '/')[last()])"/>
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
    Q: Is this thing I see on a del one? c56-0012.02 
    A: Not always, and it's an ignus fatuus! Sometimes these are superlinear insertions/modifications. Only sometimes are they pointing to left margin zones. 
    In the presence of an lb in a left margin zone, with no identifying main lb near it, what we need to find in SGA is a main surface <line> (by count of preceding-sibling::line up to its parent zone), that contains an  anchor with an xml:id that matches to a value following a '#" in a zone[@type='left_margin']/@corresp that contains the same text that follows our left-margin lb. 
    TO ENRICH the available information: If we find that main line and get its position, we can place the anchor to REFER to that line by count. 
    When we find it, we will want to place the anchor element at the moment JUST BEFORE the first lb in the left margin zone in our P1 file.
    
    THINKING IT THROUGH: 
    Where __left_margin is in presence of __main: 
    1) Does __main have an lb attached? 
       * If so, get its surface id and count number, and hunt for it in SGA.          
       * Look for an anchor element inside that line. 
            * Check if there's an anchor that corresps to a __left_margin zone. If it does, follow it and see if its text matches what we have in our rdg element as the first text node following a __left_margin lb. 
            * If there's NO anchor that corresps to a __left_margin zone, signal this so we know.
            * Check along the preceding:: and following::axis for the first available anchor[1] that corresponds to a __left_margin. Signal when you find it, and see if it has the correct text as above. 
        * If you find the main line holding the __left_margin anchor, signal success, get the main surface line position count at that moment, and place the intel in a new anchor element. The anchor element looks like this if it were on line 11 of surface c56-0012: 
        <anchor type="left_margin" loc="c56-0012__main__11" xml:id="{@xml:id}"/>  
            
    -->  
    <xsl:template match="rdg[@wit='fMS'][contains(., '__left_margin')][matches(., '&lt;lb\s+n=&#34;.+?__main__\d+&#34;')]">
     <rdg wit="@wit">
 <!-- <xsl:variable name="textUpToFirstLML" as="xs:string"><!-\- This should isolate the text up to the first left margin line. -\->
      <xsl:analyze-string select="text()" regex="^.+?__left_margin__\d+&#34;">
     <xsl:matching-substring>
         <xsl:value-of select="tokenize(., '&lt;.+?__left_margin')[1]"/>
     </xsl:matching-substring>           
      </xsl:analyze-string>   
  </xsl:variable> 
    <xsl:variable name="FirstLMLToEnd" as="xs:string"><!-\-the first LML up to the end -\-><xsl:analyze-string select="text()" regex="^.+?__left_margin__\d+&#34;.+?$">
            <xsl:matching-substring>
                <xsl:analyze-string select="." regex="&lt;.+?__left_margin__\d+&#34;.+?$">
            <xsl:matching-substring>
                <xsl:value-of select="."/>
            </xsl:matching-substring>        
                </xsl:analyze-string>
            </xsl:matching-substring>           
        </xsl:analyze-string>  
  </xsl:variable>      -->
        <xsl:analyze-string select="." regex="&lt;.+?&gt;">
            <xsl:matching-substring>
            <xsl:analyze-string select="." regex="&lt;lb\s+n=&#34;.+?__main__\d+&#34;.+?&gt;">
            <xsl:matching-substring>
                <xsl:value-of select="."/>
                <xsl:analyze-string select="." regex="n=&#34;.+?__main__\d+">
                    <xsl:matching-substring>
                 <xsl:variable name="mainLineCount" as="xs:double" select="substring-after(., 'main__') ! number()"/><xsl:message>The Line Position number is <xsl:value-of select="$mainLineCount"/>.</xsl:message>
                        <xsl:variable name="mainSurfaceId" as="xs:string" select="substring-after(., 'n=&#34;') ! tokenize(., '__')[1]"/>
                        <xsl:message>The Main Surface ID is <xsl:value-of select="$mainSurfaceId"/>.</xsl:message>
          <!--Do the lookup here: -->              
   <xsl:variable name="sgaMatchLine" as="element()*" select="$sga-mscoll//surface[@xml:id[contains(., $mainSurfaceId)]]//zone[@type='main']//line[count(preceding-sibling::line) + 1 = $mainLineCount]"/>          <xsl:choose>
       <xsl:when test="$sgaMatchLine//anchor[@xml:id = following::zone[@type='left_margin'][ancestor::surface[contains(@xml:id, $mainSurfaceId)]]/substring-after(@corresp, '#')]">
        <!--  <xsl:value-of select="$textUpToFirstLML"/>-->
        <!-- copy anchor here -->
           <xsl:message>HOORAY! ANCHOR MATCH!</xsl:message>
           <xsl:copy-of select="$sgaMatchLine//anchor[@xml:id = following::zone[@type='left_margin'][ancestor::surface[contains(@xml:id, $mainSurfaceId)]]/substring-after(@corresp, '#')]"/>
   <!--   <xsl:value-of select="$FirstLMLToEnd"/>-->
       </xsl:when>
       <xsl:otherwise>
       <!-- <xsl:comment>STILL LOOKING FOR THAT ANCHOR</xsl:comment>
           <xsl:message>STILL LOOKING FOR THAT ANCHOR</xsl:message>-->
         <!-- DO SOMETHING MORE TO LOOKUP ON PRECEDING / FOLLOWING AXIS UNTIL YOU FIND IT  <xsl:value-of select="."/>-->
           <xsl:choose><xsl:when test="$sgaMatchLine[preceding::anchor[@xml:id = following::zone[@type='left_margin'][ancestor::surface[contains(@xml:id, $mainSurfaceId)]]/substring-after(@corresp, '#')]]">  
               <xsl:message>ANCHOR MATCH ON PRECEDING AXIS</xsl:message>
               <xsl:comment>ANCHOR MATCH ON PRECEDING AXIS</xsl:comment>
               <xsl:copy-of select="$sgaMatchLine/preceding::anchor[@xml:id = following::zone[@type='left_margin'][ancestor::surface[contains(@xml:id, $mainSurfaceId)]]/substring-after(@corresp, '#')][1]"/></xsl:when>
               <xsl:when test="$sgaMatchLine[following::anchor[@xml:id = following::zone[@type='left_margin'][ancestor::surface[contains(@xml:id, $mainSurfaceId)]]/substring-after(@corresp, '#')]][1]">  
                   <xsl:message>ANCHOR MATCH ON FOLLOWING AXIS</xsl:message>
                   <xsl:comment>ANCHOR MATCH ON FOLLOWING AXIS</xsl:comment>
                   <xsl:copy-of select="$sgaMatchLine/following::anchor[@xml:id = following::zone[@type='left_margin'][ancestor::surface[contains(@xml:id, $mainSurfaceId)]]/substring-after(@corresp, '#')][1]"/></xsl:when> 
               <xsl:when test="$sgaMatchLine/ancestor::*[ancestor::surface[contains(@xml:id, $mainSurfaceId)]]//anchor[@xml:id = following::zone[@type='left_margin'][ancestor::surface[contains(@xml:id, $mainSurfaceId)]]/substring-after(@corresp, '#')][1]">
                   <xsl:message>ANCHOR MATCH from ANCESTOR AXIS AXIS</xsl:message>
                   <xsl:comment>ANCHOR MATCH from ANCESTOR AXIS</xsl:comment>   
                   <xsl:copy-of select="$sgaMatchLine/ancestor::*[ancestor::surface[contains(@xml:id, $mainSurfaceId)]]//anchor[@xml:id = following::zone[@type='left_margin'][ancestor::surface[contains(@xml:id, $mainSurfaceId)]]/substring-after(@corresp, '#')][1]"/>
               </xsl:when>
               <xsl:otherwise>
                   <xsl:message>TOO BAD: NEVER FOUND THAT ANCHOR!</xsl:message>
                   <xsl:comment>TOO BAD: NEVER FOUND THAT ANCHOR!</xsl:comment>
               </xsl:otherwise>
           </xsl:choose>
       </xsl:otherwise>
       
   </xsl:choose>      
                    </xsl:matching-substring>
                  <xsl:non-matching-substring>
                        <xsl:value-of select="."/>
                </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:matching-substring>
           <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string> 
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
        </xsl:non-matching-substring>
        </xsl:analyze-string>
     </rdg>
    </xsl:template>         
</xsl:stylesheet>