<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/website-page.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="environment" select="/m:response/m:environment"/>
        <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()"/>
        <xsl:variable name="utilities-path" select="$environment/m:url[@id eq 'utilities']/text()"/>
        
        <xsl:variable name="content">
            
            <div class="alert alert-info small text-center">
                <p>This page tracks and validates cross references between texts, specifically tei:ref nodes with a target attribute refering to the 84000 Reading Room <br/>i.e. &lt;ref target="https://read.84000.co/translation/..."/&gt;</p>
                <p>Pending references are those with the attribute @rend="pending". On publishing a text links pointing to it texts should be resolved and the pending attribute removed.</p>
            </div>
        
            <!-- Prioritise invalid targets -->
            <xsl:variable name="invalid-targets" select="m:target-text[m:ref-context[not(@target-toh-key) or @target-toh-key eq '']]"/>
            <xsl:call-template name="target-text-list">
                <xsl:with-param name="target-texts" select="$invalid-targets"/>
                <xsl:with-param name="group-id" select="'invalid-targets'"/>
                <xsl:with-param name="group-title" select="'Link(s) to invalid resources '"/>
                <xsl:with-param name="count-issues" select="count($invalid-targets/m:ref-context[not(@target-toh-key) or @target-toh-key eq ''])"/>
            </xsl:call-template>
        
            <!-- Refs with invalid domains -->
            <xsl:variable name="invalid-domains" select="m:target-text[not(@id = ($invalid-targets/@id))][m:ref-context[@target-domain-validated eq 'false']]"/>
            <xsl:call-template name="target-text-list">
                <xsl:with-param name="target-texts" select="$invalid-domains"/>
                <xsl:with-param name="group-id" select="'invalid-domains'"/>
                <xsl:with-param name="group-title" select="'Link(s) to invalid domains '"/>
                <xsl:with-param name="count-issues" select="count($invalid-domains/m:ref-context[@target-domain-validated eq 'false'])"/>
            </xsl:call-template>
        
            <!-- Texts with invalid hash -->
            <xsl:variable name="invalid-hashes" select="m:target-text[not(@id = ($invalid-targets/@id))][m:ref-context[@target-id-validated eq 'false']]"/>
            <xsl:call-template name="target-text-list">
                <xsl:with-param name="target-texts" select="$invalid-hashes"/>
                <xsl:with-param name="group-id" select="'invalid-hashes'"/>
                <xsl:with-param name="group-title" select="'Texts with invalid pointers '"/>
                <xsl:with-param name="count-issues" select="count($invalid-hashes)"/>
            </xsl:call-template>
        
            <!-- Published texts with pending refs -->
            <xsl:variable name="published-pending" select="m:target-text[not(@id = ($invalid-targets/@id))][@translation-status-group eq 'published'][m:ref-context[tei:ref[@rend eq 'pending']]]"/>
            <xsl:call-template name="target-text-list">
                <xsl:with-param name="target-texts" select="$published-pending"/>
                <xsl:with-param name="group-id" select="'published-pending'"/>
                <xsl:with-param name="group-title" select="'Pending references to published texts '"/>
                <xsl:with-param name="count-issues" select="count($published-pending/m:ref-context[tei:ref[@rend eq 'pending']])"/>
            </xsl:call-template>
        
            <!-- Not-published texts with active refs -->
            <xsl:variable name="non-published-active" select="m:target-text[not(@id = ($invalid-targets/@id))][not(@translation-status-group eq 'published')][m:ref-context[tei:ref[not(@rend eq 'pending')]]]"/>
            <xsl:call-template name="target-text-list">
                <xsl:with-param name="target-texts" select="$non-published-active"/>
                <xsl:with-param name="group-id" select="'non-published-active'"/>
                <xsl:with-param name="group-title" select="'Active references to not published texts '"/>
                <xsl:with-param name="count-issues" select="count($non-published-active/m:ref-context[tei:ref[not(@rend eq 'pending')]])"/>
            </xsl:call-template>
        
            <!-- The rest -->
            <xsl:variable name="remaining-texts" select="m:target-text[not(@id = ($invalid-targets/@id))][not(@id = ($invalid-targets/@id, $invalid-domains/@id, $invalid-hashes/@id, $published-pending/@id, $non-published-active/@id))]"/>
            <xsl:call-template name="target-text-list">
                <xsl:with-param name="target-texts" select="$remaining-texts"/>
                <xsl:with-param name="group-id" select="'remainder'"/>
                <xsl:with-param name="group-title" select="'Remaining texts referenced in other texts '"/>
            </xsl:call-template>
            
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
        
        <xsl:param name="target-texts" as="element(m:target-text)*" required="yes"/>
        <xsl:param name="group-id" as="xs:string" required="yes"/>
        <xsl:param name="group-title" as="xs:string" required="yes"/>
        <xsl:param name="count-issues" as="xs:integer" select="-1"/>
        
        <div class="div-list">
            
            <div class="heading">
                <xsl:value-of select="$group-title"/>
                <xsl:if test="$count-issues gt -1">
                    <span class="badge badge-notification">
                        <xsl:if test="$count-issues eq 0">
                            <xsl:attribute name="class" select="'badge badge-notification badge-muted'"/>
                        </xsl:if>
                        <xsl:value-of select="$count-issues"/>
                    </span>
                </xsl:if>
            </div>
            
            <xsl:for-each select="$target-texts">
                
                <xsl:sort select="number(m:toh/@number)"/>
                <xsl:sort select="m:toh/@letter"/>
                <xsl:sort select="number(m:toh/@chapter-number)"/>
                <xsl:sort select="m:toh/@chapter-letter"/>
                
                <xsl:variable name="target-text" select="."/>
                <xsl:variable name="text-row-id" select="concat('target-text-', $group-id, '-', position())"/>
                
                <div class="item">
                    
                    <div role="tab">
                        
                        <xsl:attribute name="id" select="concat($text-row-id, '-heading')"/>
                        
                        <a class="center-vertical full-width collapsed" role="button" data-toggle="collapse" aria-expanded="false">
                            
                            <xsl:attribute name="href" select="concat('#', $text-row-id, '-detail')"/>
                            <xsl:attribute name="aria-controls" select="concat($text-row-id, '-detail')"/>
                            
                            <span>
                                
                                <xsl:choose>
                                    
                                    <xsl:when test="$target-text[@id gt '']">
                                        
                                        <span>
                                            <!-- Toh / Title -->
                                            <xsl:value-of select="'&lt;ref/&gt;s targeting '"/>
                                            <strong>
                                                <xsl:value-of select="$target-text/m:toh/m:full"/>
                                            </strong>
                                            <xsl:value-of select=" ' / '"/>
                                            <xsl:value-of select="$target-text/@id"/>
                                            <xsl:value-of select=" ' / '"/>
                                            <xsl:value-of select="($target-text/m:titles/m:title[@xml:lang eq 'en'][text()], $target-text/m:titles/m:title[@xml:lang eq 'Sa-Ltn'][text()], $target-text/m:titles/m:title[@xml:lang eq 'Bo-Ltn'][text()])[1]"/>
                                        </span>
                                        
                                    </xsl:when>
                                    
                                    <xsl:otherwise>
                                        <span class="text-danger">
                                            <xsl:value-of select="concat($target-text/@resource-id, ' is not valid')"/>
                                        </span>
                                    </xsl:otherwise>
                                    
                                </xsl:choose>
                                
                                <xsl:value-of select=" ' '"/>
                                
                                <!-- Published flag -->
                                <span class="label label-warning">
                                    <xsl:choose>
                                        <xsl:when test="$target-text[@translation-status-group eq 'published']">
                                            <xsl:attribute name="class" select="'label label-success'"/>
                                            <xsl:value-of select="'Text published'"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="'Text not published'"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </span>
                                <xsl:value-of select="' '"/>
                                
                                <!-- Refs pending -->
                                <xsl:if test="$target-text/m:ref-context[tei:ref[@rend eq 'pending']]">
                                    <span class="label label-warning">
                                        <xsl:value-of select="concat(count($target-text/m:ref-context/tei:ref[@rend eq 'pending']), ' pending ref(s)')"/>
                                    </span>
                                    <xsl:value-of select="' '"/>
                                </xsl:if>
                                
                                <!-- Refs active -->
                                <xsl:if test="$target-text/m:ref-context[tei:ref[not(@rend eq 'pending')]]">
                                    <span class="label label-success">
                                        <xsl:value-of select="concat(count($target-text/m:ref-context/tei:ref[not(@rend eq 'pending')]), ' active ref(s)')"/>
                                    </span>
                                </xsl:if>
                                
                            </span>
                            
                            <span class="text-right">
                                <i class="fa fa-plus collapsed-show"/>
                                <i class="fa fa-minus collapsed-hide"/>
                            </span>
                            
                        </a>
                    </div>
                    
                    <div class="collapse" role="tabpanel" aria-expanded="false">
                        
                        <xsl:attribute name="id" select="concat($text-row-id, '-detail')"/>
                        <xsl:attribute name="aria-labelledby" select="concat($text-row-id, '-heading')"/>
                        
                        <div class="top-margin">
                            <xsl:for-each-group select="$target-text/m:ref-context" group-by="m:toh/@key">
                                
                                <xsl:sort select="number(m:toh[1]/@number)"/>
                                <xsl:sort select="m:toh[1]/@letter"/>
                                <xsl:sort select="number(m:toh[1]/@chapter-number)"/>
                                <xsl:sort select="m:toh[1]/@chapter-letter"/>
                                
                                <div class="bottom-margin">
                                    
                                    <div class="small">
                                        <xsl:value-of select="m:toh/m:full"/>
                                        <xsl:value-of select="' / '"/>
                                        <xsl:value-of select="(m:titles/m:title[@xml:lang eq 'en'][text()], m:titles/m:title[@xml:lang eq 'Sa-Ltn'][text()], m:titles/m:title[@xml:lang eq 'Bo-Ltn'][text()])[1]"/>
                                        <xsl:value-of select="' / '"/>
                                        <xsl:value-of select="@resource-id"/>
                                    </div>
                                    
                                    <xsl:for-each select="fn:current-group()">
                                        
                                        <xsl:variable name="target-file" select="tokenize(tei:ref/@target, '/')[last()]"/>
                                        
                                        <div>
                                            <ul class="list-inline inline-dots">
                                                <li>
                                                    
                                                    <xsl:value-of select="' ↳ '"/>
                                                    
                                                    <code class="small">
                                                        <xsl:if test="@target-domain-validated eq 'false'">
                                                            <xsl:attribute name="class" select="'small red-alert'"/>
                                                        </xsl:if>
                                                        <xsl:value-of select="concat('@target=&#34;', tei:ref/@target, '&#34;')"/>
                                                    </code>
                                                    
                                                    <xsl:value-of select="' '"/>
                                                    
                                                    <xsl:choose>
                                                        <xsl:when test="tei:ref[@rend eq 'pending']">
                                                            <span class="label label-warning">
                                                                <xsl:value-of select="'Pending'"/>
                                                            </span>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <span class="label label-info">
                                                                <xsl:value-of select="'Active'"/>
                                                            </span>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                    
                                                    <xsl:if test="@target-id-validated eq 'false'">
                                                        <xsl:value-of select="' '"/>
                                                        <span class="label label-danger">
                                                            <xsl:value-of select="concat('@xml:id=&#34;', @target-hash, '&#34; not found in ', @target-toh-key)"/>
                                                        </span>
                                                    </xsl:if>
                                                    
                                                </li>
                                                <li>
                                                    <a target="_blank" class="small">
                                                        <xsl:attribute name="href" select="tei:ref/@target"/>
                                                        <xsl:value-of select="'actual link'"/>
                                                    </a>
                                                </li>
                                                <li>
                                                    <a target="_blank" class="small">
                                                        <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', $target-file)"/>
                                                        <xsl:value-of select="'local link'"/>
                                                    </a>
                                                </li>
                                            </ul>
                                        </div>
                                        
                                    </xsl:for-each>
                                    
                                </div>
                            </xsl:for-each-group>
                            
                        </div>
                        
                    </div>
                    
                </div>
                
            </xsl:for-each>
            
        </div>
        
    </xsl:template>
    
</xsl:stylesheet>