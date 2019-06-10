<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xpath-default-namespace="http://www.tei-c.org/ns/1.0"  xmlns:pitt="https://github.com/ebeshero/Pittsburgh_Frankenstein"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:mith="http://mith.umd.edu/sc/ns1#" xmlns:th="http://www.blackmesatech.com/2017/nss/trojan-horse"
    exclude-result-prefixes="xs th pitt mith tei" version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
 <!-- 2019-06-09 ebb: Last stage in the pipeline: remove the white-space-only text nodes in between elements for ease of pointing and parsing. Run with saxon at command line with:
java -jar saxon.jar -s:P5-output/ -xsl:whiteSpaceReducer.xsl -o:P5-trimmedWS 
 -->   
    <xsl:template match="div[@type='collation']//text()[matches(., '^\s+$')]"/>

</xsl:stylesheet>