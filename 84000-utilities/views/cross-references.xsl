<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/xslt/webpage.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:variable name="environment" select="/m:response/m:environment"/>
    <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()"/>
    <xsl:variable name="utilities-path" select="$environment/m:url[@id eq 'utilities']/text()"/>
    <xsl:variable name="source-texts" select="/m:response/m:source-text"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            
            <div class="alert alert-info small text-center">
                <p>This page tracks and validates cross references between texts, specifically tei:ref nodes with a target attribute refering to the 84000 Reading Room <br/>i.e. &lt;ref target="https://read.84000.co/translation/..."/&gt;</p>
                <p>Pending references are those with the attribute @rend="pending". On publishing a text links pointing to it texts should be resolved and the pending attribute removed.</p>
            </div>
            
            <xsl:for-each select="('issues-translated','issues-inprogress','no-issues')">
                
                <xsl:variable name="ref-type" select="."/>
                
                <xsl:choose>
                    <xsl:when test="$ref-type eq 'issues-translated'">
                        <p>Published texts with cross-reference issues</p>
                    </xsl:when>
                    <xsl:when test="$ref-type eq 'issues-inprogress'">
                        <p>Unpublished texts with cross-reference issues</p>
                    </xsl:when>
                    <xsl:otherwise>
                        <p>Cross-references without issues</p>
                    </xsl:otherwise>
                </xsl:choose>
                
                <div id="source-texts-{ $ref-type }" class="list-group accordion accordion-bordered accordion-background" role="tablist" aria-multiselectable="false">
                    
                    <xsl:variable name="ref-type-source-texts" select="if($ref-type eq 'issues-translated') then $source-texts[@status-group eq 'published'][m:ref[m:issue]] else if($ref-type eq 'issues-inprogress') then $source-texts[not(@status-group eq 'published')][m:ref[m:issue]] else $source-texts[not(m:ref[m:issue])]"/>
                    
                    <xsl:choose>
                        <xsl:when test="$ref-type-source-texts">
                            
                            <xsl:for-each select="$ref-type-source-texts">
                                
                                <xsl:sort select="count(m:ref[m:issue])" order="descending"/>
                                <xsl:sort select="(m:toh ! 0, 1)[1]"/>
                                <xsl:sort select="number(m:toh/@number)"/>
                                <xsl:sort select="m:toh/@letter"/>
                                <xsl:sort select="number(m:toh/@chapter-number)"/>
                                <xsl:sort select="m:toh/@chapter-letter"/>
                                
                                <xsl:call-template name="expand-item">
                                    
                                    <xsl:with-param name="id" select="concat('source-text-', @id)"/>
                                    <xsl:with-param name="accordion-selector" select="concat('#source-texts-', $ref-type)"/>
                                    <xsl:with-param name="persist" select="true()"/>
                                    <xsl:with-param name="title-opener" select="true()"/>
                                    
                                    <xsl:with-param name="title">
                                        <div class="center-vertical align-left">
                                            <span>
                                                <xsl:choose>
                                                    <xsl:when test="$ref-type = ('issues-translated', 'issues-inprogress')">
                                                        <span class="badge badge-notification">
                                                            <xsl:value-of select="count(m:ref[m:issue])"/>
                                                        </span>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <span class="badge badge-notification badge-muted">
                                                            <xsl:value-of select="count(m:ref)"/>
                                                        </span>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </span>
                                            <span>
                                                <xsl:value-of select="common:limit-str(string-join((m:toh/m:full, (m:titles/m:title[@xml:lang eq 'en'][text()], m:titles/m:title[@xml:lang eq 'Sa-Ltn'][text()], m:titles/m:title[@xml:lang eq 'Bo-Ltn'][text()])[1], @id), ' / '), 120)"/>
                                            </span>
                                            <span>
                                                <span>
                                                    <xsl:attribute name="class">
                                                        <xsl:choose>
                                                            <xsl:when test="@status-group eq 'published'">
                                                                <xsl:value-of select="'label label-success'"/>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:value-of select="'label label-default'"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </xsl:attribute>
                                                    <xsl:value-of select="common:translation-status(@status-group)"/>
                                                </span>
                                            </span>
                                        </div>
                                    </xsl:with-param>
                                    
                                    <xsl:with-param name="content">
                                        <table class="table no-border full-width sml-margin top">
                                            <tbody>
                                                <xsl:for-each select="m:ref">
                                                    
                                                    <xsl:sort select="count(m:issue)" order="descending"/>
                                                    
                                                    <tr>
                                                        <td>
                                                            <xsl:value-of select="' ↳ '"/>
                                                        </td>
                                                        <td>
                                                            <code class="small">
                                                                <xsl:if test="m:issue[@type = ('invalid-domain', 'invalid-text', 'invalid-id', 'invalid-url')]">
                                                                    <xsl:attribute name="class" select="'small red-alert'"/>
                                                                </xsl:if>
                                                                <xsl:value-of select="concat('@target=&#34;', @target, '&#34;')"/>
                                                            </code>
                                                            <xsl:if test="m:issue">
                                                                <ul class="small text-muted sml-margin top bottom">
                                                                    <xsl:if test="m:issue[@type eq 'invalid-domain']">
                                                                        <li>
                                                                            <xsl:value-of select="'Invalid domain'"/>
                                                                        </li>
                                                                    </xsl:if>
                                                                    <xsl:if test="m:issue[@type eq 'invalid-text']">
                                                                        <li>
                                                                            <xsl:value-of select="concat('Invalid text id: ', @target-page)"/>
                                                                        </li>
                                                                    </xsl:if>
                                                                    <xsl:if test="m:issue[@type eq 'invalid-id']">
                                                                        <li>
                                                                            <xsl:value-of select="concat('Incorrect xml:id: ', @target-hash)"/>
                                                                        </li>
                                                                    </xsl:if>
                                                                    <xsl:if test="m:issue[@type eq 'invalid-url']">
                                                                        <li>
                                                                            <xsl:value-of select="concat('Invalid url: ', @target-page)"/>
                                                                        </li>
                                                                    </xsl:if>
                                                                    <xsl:if test="m:issue[@type eq 'pending-link-published-text']">
                                                                        <li>
                                                                            <xsl:value-of select="'Pending link to a published text'"/>
                                                                        </li>
                                                                    </xsl:if>
                                                                    <xsl:if test="m:issue[@type eq 'active-link-unpublished-text']">
                                                                        <li>
                                                                            <xsl:value-of select="'Active link to an unpublished text'"/>
                                                                        </li>
                                                                    </xsl:if>
                                                                </ul>
                                                            </xsl:if>
                                                        </td>
                                                        <td>
                                                            <xsl:choose>
                                                                <xsl:when test="m:issue[@type eq 'pending-link-published-text']">
                                                                    <span class="label label-danger">
                                                                        <xsl:value-of select="'Pending link'"/>
                                                                    </span>
                                                                </xsl:when>
                                                                <xsl:when test="m:issue[@type eq 'active-link-unpublished-text']">
                                                                    <span class="label label-danger">
                                                                        <xsl:value-of select="'Active link'"/>
                                                                    </span>
                                                                </xsl:when>
                                                                <xsl:when test="@rend eq 'pending'">
                                                                    <span class="label label-warning">
                                                                        <xsl:value-of select="'Pending link'"/>
                                                                    </span>
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    <span class="label label-info">
                                                                        <xsl:value-of select="'Active link'"/>
                                                                    </span>
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                        </td>
                                                        <td>
                                                            <xsl:if test="m:target-text">
                                                                <span>
                                                                    <xsl:attribute name="class">
                                                                        <xsl:choose>
                                                                            <xsl:when test="m:target-text[@status-group eq 'published']">
                                                                                <xsl:value-of select="'label label-success'"/>
                                                                            </xsl:when>
                                                                            <xsl:otherwise>
                                                                                <xsl:value-of select="'label label-default'"/>
                                                                            </xsl:otherwise>
                                                                        </xsl:choose>
                                                                    </xsl:attribute>
                                                                    <xsl:value-of select="concat(m:target-text/m:toh/m:full, ' ', common:translation-status(m:target-text/@status-group))"/>
                                                                </span>
                                                            </xsl:if>
                                                        </td>
                                                        <td class="nowrap">
                                                            <a target="_blank" class="small">
                                                                <xsl:attribute name="href" select="@target"/>
                                                                <xsl:value-of select="'actual link'"/>
                                                            </a>
                                                        </td>
                                                        <td class="nowrap">
                                                            <span>
                                                                <a target="_blank" class="small">
                                                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', @target-path)"/>
                                                                    <xsl:value-of select="'local link'"/>
                                                                </a>
                                                            </span>
                                                        </td>                                            
                                                    </tr>
                                                    
                                                </xsl:for-each>
                                            </tbody>
                                        </table>
                                    </xsl:with-param>
                                    
                                </xsl:call-template>
                                
                            </xsl:for-each>
                            
                        </xsl:when>
                        <xsl:otherwise>
                            
                            <hr class="sml-margin"/>
                            
                            <p class="text-muted italic">No texts to display</p>
                            
                        </xsl:otherwise>
                    </xsl:choose>
                </div>
                
            </xsl:for-each>
            
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
    
</xsl:stylesheet>