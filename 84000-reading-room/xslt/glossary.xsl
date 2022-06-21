<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:util="http://exist-db.org/xquery/util" xmlns:functx="http://www.functx.com" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="tei-to-xhtml.xsl"/>
    
    <xsl:template name="glossary-tabs">
        
        <xsl:param name="page-url" as="xs:string"/>
        <xsl:param name="term-langs" as="element(m:term-langs)?"/>
        <xsl:param name="entity-flags" as="element(m:entity-flags)?"/>
        <xsl:param name="selected-type" as="element(m:type)*"/>
        <xsl:param name="active-tab" as="xs:string?"/>
        <xsl:param name="search-text" as="xs:string?"/>
        <xsl:param name="entry-label" as="element(m:label)?"/>
        
        <xsl:variable name="internal-link-attrs" select="(concat('term-lang=', $term-langs/m:lang[@selected eq 'selected'][1]/@id), $selected-type ! concat('term-type[]=', @id), concat('letter=', ''), concat('search=', $search-text), m:view-mode-parameter((),()))" as="xs:string*"/>
        
        <div class="tabs-container-center">
            <ul class="nav nav-tabs" role="tablist">
                
                <!-- Language tabs -->
                <xsl:for-each select="$term-langs/m:lang">
                    
                    <xsl:variable name="internal-link-attrs" select="(concat('term-lang=', @id), $selected-type ! concat('term-type[]=', @id), concat('letter=', ''), concat('search=', $search-text), m:view-mode-parameter((),()))"/>
                    
                    <li role="presentation">
                        <xsl:if test="$active-tab eq @id">
                            <xsl:attribute name="class" select="'active'"/>
                        </xsl:if>
                        <a>
                            <xsl:attribute name="href" select="common:internal-link('/glossary/search.html', $internal-link-attrs, '', $root/m:response/@lang)"/>
                            <xsl:attribute name="data-loading" select="'Loading...'"/>
                            <xsl:value-of select="text()"/>
                        </a>
                    </li>
                    
                </xsl:for-each>
                
                <!-- Downloads tab -->
                <li role="presentation" class="icon">
                    <xsl:if test="$active-tab eq 'downloads'">
                        <xsl:attribute name="class" select="'icon active'"/>
                    </xsl:if>
                    <a>
                        <xsl:attribute name="href" select="common:internal-link('/glossary/downloads.html', $internal-link-attrs, '', $root/m:response/@lang)"/>
                        <xsl:attribute name="title" select="'Downloads'"/>
                        <xsl:attribute name="data-loading" select="'Loading...'"/>
                        <i class="fa fa-cloud-download"/>
                        <xsl:value-of select="' Downloads'"/>
                    </a>
                </li>
                
                <!-- Entry tab -->
                <xsl:if test="$entry-label">
                    <li role="presentation" class="icon active">
                        <a>
                            <xsl:attribute name="href" select="common:internal-link($page-url, (m:view-mode-parameter((),())), '', $root/m:response/@lang)"/>
                            <xsl:attribute name="title" select="'Downloads'"/>
                            <xsl:attribute name="data-loading" select="'Loading...'"/>
                            <xsl:value-of select="'Entry'"/>
                        </a>
                    </li>
                </xsl:if>
                
                <!-- Flag tabs -->
                <xsl:if test="$tei-editor">
                    <xsl:for-each select="$entity-flags/m:flag">
                        <li role="presentation" class="icon">
                            <xsl:if test="$active-tab eq @id">
                                <xsl:attribute name="class" select="'active icon'"/>
                            </xsl:if>
                            <a class="editor">
                                <xsl:attribute name="href" select="common:internal-link(concat('/glossary/search.html?flagged=', @id), (m:view-mode-parameter((),())), '', $root/m:response/@lang)"/>
                                <xsl:attribute name="title" select="concat('Filter by ', m:label)"/>
                                <xsl:attribute name="data-loading" select="'Loading...'"/>
                                <xsl:value-of select="m:label"/>
                            </a>
                        </li>
                    </xsl:for-each>
                </xsl:if>
                
                <!-- Editor link -->
                <xsl:if test="$tei-editor or $tei-editor-off">
                    <li>
                        <a>
                            <xsl:choose>
                                <xsl:when test="$tei-editor-off">
                                    <xsl:attribute name="href" select="common:internal-link($page-url, m:view-mode-parameter('editor'), '', $root/m:response/@lang)"/>
                                    <xsl:attribute name="class" select="'editor'"/>
                                    <xsl:attribute name="data-loading" select="'Loading...'"/>
                                    <xsl:value-of select="'Show Editor'"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="href" select="$page-url"/>
                                    <xsl:attribute name="class" select="'editor'"/>
                                    <xsl:attribute name="data-loading" select="'Loading...'"/>
                                    <xsl:value-of select="'Hide Editor'"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </a>
                    </li>
                </xsl:if>
                
            </ul>
        </div>
    </xsl:template>
    
    <xsl:template name="editor-summary">
        
        <xsl:param name="entity" as="element(m:entity)?"/>
        
        <xsl:if test="$tei-editor and $entity">
            
            <xsl:variable name="instances-flagged" select="$entity/m:instance[m:flag]"/>
            <xsl:variable name="related-entries" select="key('related-entries', $entity/m:instance/@id, $root)"/>
            <xsl:variable name="related-entries-excluded" select="$related-entries[parent::m:text/@glossary-status eq 'excluded']"/>
            
            <!-- Summary -->
            <xsl:variable name="summary">
                
                <div class="center-vertical align-left">
                    
                    <xsl:if test="$entity/m:content[@type eq 'glossary-notes']">
                        <span>
                            <span class="label label-warning">
                                <xsl:value-of select="count($entity/m:content[@type eq 'glossary-notes'])"/>
                                <xsl:value-of select="if (count($entity/m:content[@type eq 'glossary-notes']) eq 1) then ' note' else ' notes'"/>
                            </span>
                        </span>
                    </xsl:if>
                    
                    <xsl:if test="$related-entries-excluded">
                        <span>
                            <span class="label label-danger">
                                <xsl:value-of select="count($related-entries-excluded)"/>
                                <xsl:value-of select="if (count($related-entries-excluded) eq 1) then ' entry in an excluded text' else ' entries in excluded texts'"/>
                            </span>
                        </span>
                    </xsl:if>
                    
                    <xsl:if test="$instances-flagged">
                        <span>
                            <span class="label label-danger">
                                <xsl:choose>
                                    <xsl:when test="count($entity/m:instance[@type eq 'glossary-item']) eq count($entity/m:instance[@type eq 'glossary-item'][m:flag])">
                                        <xsl:value-of select="'All entries are flagged, this entity is EXCLUDED from the public glossary'"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="count($instances-flagged)"/>
                                        <xsl:value-of select="if (count($instances-flagged) eq 1) then ' entry flagged' else ' entries flagged'"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </span>
                        </span>
                    </xsl:if>
                    
                    <!-- Editor link -->
                    <span>
                        <a target="84000-operations" class="editor">
                            <xsl:attribute name="href" select="concat('/edit-entity.html?entity-id=', $entity/@xml:id, '#ajax-source')"/>
                            <xsl:attribute name="data-ajax-target" select="'#popup-footer-editor .data-container'"/>
                            <xsl:value-of select="'Entity editor'"/>
                        </a>
                    </span>
                    
                </div>
                
            </xsl:variable>
            
            <xsl:choose>
                
                <!-- Show expandable with notes -->
                <xsl:when test="$entity/m:content[@type eq 'glossary-notes']">
                    
                    <div id="editor-summary-accordion-{ $entity/@xml:id }" class="bottom-margin">
                        
                        <xsl:call-template name="expand-item">
                            
                            <xsl:with-param name="id" select="'editor-summary-' || $entity/@xml:id"/>
                            <xsl:with-param name="accordion-selector" select="'#editor-summary-accordion-' || $entity/@xml:id"/>
                            
                            <xsl:with-param name="title">
                                <xsl:sequence select="$summary"/>
                            </xsl:with-param>
                            
                            <xsl:with-param name="content">
                                
                                <hr class="sml-margin"/>
                                <div>
                                    <xsl:for-each select="$entity/m:content[@type eq 'glossary-notes']">
                                        <p class="sml-margin bottom small">
                                            <xsl:value-of select="."/>
                                        </p>
                                    </xsl:for-each>
                                </div>
                                
                            </xsl:with-param>
                            
                        </xsl:call-template>
                        
                    </div>
                    
                </xsl:when>
                
                <!-- Just an editor link -->
                <xsl:otherwise>
                    <div class="clearfix bottom-margin">
                        <xsl:sequence select="$summary"/>
                    </div>
                </xsl:otherwise>
                
            </xsl:choose>
            
        </xsl:if>
        
    </xsl:template>
    
    <xsl:template name="entity-types-list">
        
        <xsl:param name="entity" as="element(m:entity)?"/>
        
        <xsl:if test="$entity">
            <ul class="list-inline">
                
                <xsl:for-each select="/m:response/m:request/m:entity-types/m:type[@id = $entity/m:type/@type]">
                    <li>
                        <span class="label label-info">
                            <xsl:value-of select="m:label[@type eq 'singular']"/>
                        </span>
                    </li>
                </xsl:for-each>
                
                <xsl:if test="/m:response/m:request/m:entity-types/m:type[@id = $entity/m:type/@type][@provisional]">
                    <li>
                        <span class="label label-default">
                            <xsl:value-of select="'Note: this data is still being sorted'"/>
                        </span>
                    </li>
                </xsl:if>
                
            </ul>
        </xsl:if>
        
    </xsl:template>
    
</xsl:stylesheet>