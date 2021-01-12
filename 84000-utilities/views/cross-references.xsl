<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/website-page.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="environment" select="/m:response/m:environment"/>
        <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()"/>
        <xsl:variable name="utilities-path" select="$environment/m:url[@id eq 'utilities']/text()"/>
        
        <xsl:variable name="content">
            
            <div class="alert alert-info small text-center">
                <p>
                    <xsl:text>
                        This page lists the cross references between texts, specifically ref nodes with a  target attribute refering to the 84000 Reading Room &lt;ref target="https://read.84000.co/translation/..."/&gt; 
                    </xsl:text>
                </p>
                <p>
                    <xsl:text>
                        Pending references are those with the attribute @rend="pending". On publishing a text links pointing to it texts should be resolved and the pending attribute removed.
                    </xsl:text>
                </p>
            </div>
            
            <div class="div-list">
                
                <!-- Prioritise invalid targets -->
                <xsl:variable name="invalid-targets" select="m:target-text[not(@id gt '')]"/>
                <xsl:if test="$invalid-targets">
                    <div class="heading text-danger">
                        <xsl:value-of select="'Link(s) to invalid resources: '"/>
                    </div>
                    <xsl:call-template name="target-text-list">
                        <xsl:with-param name="target-texts" select="$invalid-targets"/>
                    </xsl:call-template>
                </xsl:if>
                
                <!-- Published texts with pending refs -->
                <xsl:variable name="published-pending" select="m:target-text[@translation-status-group eq 'published'][m:ref-context[tei:ref[@rend eq 'pending']]]"/>
                <xsl:if test="$published-pending">
                    <div class="heading">
                        <xsl:value-of select="'Published texts with pending refs'"/>
                    </div>
                    <xsl:call-template name="target-text-list">
                        <xsl:with-param name="target-texts" select="$published-pending"/>
                    </xsl:call-template>
                </xsl:if>
                
                <!-- The rest -->
                <xsl:variable name="remainder" select="m:target-text[not(@id = ($invalid-targets/@id, $published-pending/@id))]"/>
                <xsl:if test="$remainder">
                    <xsl:if test="$invalid-targets or $published-pending">
                        <div class="heading">
                            <xsl:value-of select="'Remaining refs'"/>
                        </div>
                    </xsl:if>
                    <xsl:call-template name="target-text-list">
                        <xsl:with-param name="target-texts" select="$remainder"/>
                    </xsl:call-template>
                </xsl:if>
                
            </div>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Cross-references | 84000 Utilities'"/>
            <xsl:with-param name="page-description" select="'Cross-references between texts'"/>
            <xsl:with-param name="content">
                <xsl:call-template name="utilities-page">
                    <xsl:with-param name="content" select="$content"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template name="target-text-list">
        
        <xsl:param name="target-texts" as="element(m:target-text)*"/>
        
        <xsl:for-each select="$target-texts">
            
            <xsl:sort select="number(m:toh/@number)"/>
            <xsl:sort select="m:toh/@letter"/>
            <xsl:sort select="number(m:toh/@chapter-number)"/>
            <xsl:sort select="m:toh/@chapter-letter"/>
            
            <xsl:variable name="toh-key" select="m:toh/@key"/>
            <xsl:variable name="text-row-id" select="concat('text-', $toh-key)"/>
            
            <div class="item">
                
                <div role="tab">
                    
                    <xsl:attribute name="id" select="concat($text-row-id, '-heading')"/>
                    
                    <a class="center-vertical full-width collapsed" role="button" data-toggle="collapse" aria-expanded="false">
                        
                        <xsl:attribute name="href" select="concat('#', $text-row-id, '-detail')"/>
                        <xsl:attribute name="aria-controls" select="concat($text-row-id, '-detail')"/>
                        
                        <xsl:choose>
                            
                            <xsl:when test="@id gt ''">
                                
                                <span>
                                    
                                    <!-- Toh / Title -->
                                    <xsl:value-of select="m:toh/m:full"/>
                                    <xsl:value-of select=" ' / '"/>
                                    <xsl:value-of select="(m:titles/m:title[@xml:lang eq 'en'][text()], m:titles/m:title[@xml:lang eq 'Sa-Ltn'][text()], m:titles/m:title[@xml:lang eq 'Bo-Ltn'][text()])[1]"/>
                                    <xsl:value-of select=" ' '"/>
                                    
                                    <!-- Published flag -->
                                    <xsl:if test="@translation-status-group eq 'published'">
                                        <span class="label label-success">
                                            <xsl:value-of select="'Published'"/>
                                        </span>
                                        <xsl:value-of select="' '"/>
                                    </xsl:if>
                                    
                                    <!-- Refs pending -->
                                    <xsl:if test="m:ref-context[tei:ref[@rend eq 'pending']]">
                                        <span class="label label-warning">
                                            <xsl:if test="@translation-status-group eq 'published'">
                                                <xsl:attribute name="class" select="'label label-danger'"/>
                                            </xsl:if>
                                            <xsl:value-of select="concat(count(m:ref-context/tei:ref[@rend eq 'pending']), ' pending')"/>
                                        </span>
                                        <xsl:value-of select="' '"/>
                                    </xsl:if>
                                    
                                    <!-- Refs active -->
                                    <xsl:if test="m:ref-context[tei:ref[not(@rend eq 'pending')]]">
                                        <span class="label label-info">
                                            <xsl:value-of select="concat(count(m:ref-context/tei:ref[not(@rend eq 'pending')]), ' active')"/>
                                        </span>
                                    </xsl:if>
                                    
                                </span>
                                
                            </xsl:when>
                            
                            <xsl:otherwise>
                                <span class="text-danger">
                                    <xsl:value-of select="concat(@resource-id, ' is not valid')"/>
                                </span>
                            </xsl:otherwise>
                            
                        </xsl:choose>
                        
                        <span class="text-right">
                            <i class="fa fa-plus collapsed-show"/>
                            <i class="fa fa-minus collapsed-hide"/>
                        </span>
                        
                    </a>
                </div>
                
                <div class="collapse" role="tabpanel" aria-expanded="false">
                    
                    <xsl:attribute name="id" select="concat($text-row-id, '-detail')"/>
                    <xsl:attribute name="aria-labelledby" select="concat($text-row-id, '-heading')"/>
                    
                    <h4>
                        <xsl:value-of select="'Referenced in:'"/>
                    </h4>
                
                    <xsl:for-each select="m:ref-context">
                        
                        <div>
                            <xsl:value-of select="m:toh/m:full"/>
                            <xsl:value-of select="' / '"/>
                            <xsl:value-of select="(m:titles/m:title[@xml:lang eq 'en'][text()], m:titles/m:title[@xml:lang eq 'Sa-Ltn'][text()], m:titles/m:title[@xml:lang eq 'Bo-Ltn'][text()])[1]"/>
                            <xsl:value-of select="' '"/>
                        </div>
                        
                        <code>&lt;ref target="<xsl:value-of select="tei:ref/@target"/>"<xsl:if test="tei:ref[@rend]"> rend="<xsl:value-of select="tei:ref/@rend"/>"</xsl:if>/&gt;</code>
                            
                    </xsl:for-each>
                    
                </div>
                
            </div>
        
        </xsl:for-each>
        
    </xsl:template>
    
</xsl:stylesheet>