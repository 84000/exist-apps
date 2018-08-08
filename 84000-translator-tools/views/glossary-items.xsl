<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/xslt/tei-to-xhtml.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="environment" select="doc(/m:response/@environment-path)/m:environment"/>
        <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()"/>
        
        <xsl:for-each select="m:glossary/m:item">
             <div class="glossary-item">
                 
                 <xsl:variable name="uid" select="@uid/string()"/>
                 
                 <div class="title">
                     in
                     <a>
                         <xsl:attribute name="href" select="concat($reading-room-path ,'/translation/', @translation-id, '.html', '#', $uid)"/>
                         <xsl:apply-templates select="m:translation/m:title/text()"/>
                     </a>
                     <label class="label label-default pull-right">
                         <xsl:choose>
                             <xsl:when test="@type eq 'term'">Term</xsl:when>
                             <xsl:when test="@type eq 'person'">Person</xsl:when>
                             <xsl:when test="@type eq 'place'">Place</xsl:when>
                             <xsl:when test="@type eq 'text'">Text</xsl:when>
                         </xsl:choose>
                     </label>
                 </div>
                 
                 <div class="row">
                     <xsl:if test="m:term">
                         <div class="col-sm-6">
                             <ul>
                                 <xsl:for-each select="m:term">
                                     <xsl:if test="text()">
                                         <li>
                                             <span>
                                                 <xsl:attribute name="lang" select="@xml:lang"/>
                                                 <xsl:if test="@xml:lang eq 'bo'">
                                                     <xsl:attribute name="class" select="'text-bo'"/>
                                                 </xsl:if>
                                                 <xsl:apply-templates select="text()"/>
                                             </span>
                                         </li>
                                     </xsl:if>
                                 </xsl:for-each>
                             </ul>
                         </div>
                     </xsl:if>
                     <xsl:if test="m:definitions/m:definition">
                         <div class="col-sm-6">
                             <xsl:for-each select="m:definitions/m:definition">
                                 <p class="text-muted small">
                                     <xsl:apply-templates select="node()"/>
                                 </p>
                             </xsl:for-each>
                         </div>
                     </xsl:if>    
                 </div>
                 
             </div>
         </xsl:for-each>
         
    </xsl:template>
    
</xsl:stylesheet>