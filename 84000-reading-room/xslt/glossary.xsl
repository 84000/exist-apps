<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:util="http://exist-db.org/xquery/util" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:functx="http://www.functx.com" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="tei-to-xhtml.xsl"/>
    
    <xsl:template name="glossary-tabs">
        
        <xsl:param name="page-url" as="xs:string"/>
        <xsl:param name="term-langs" as="element(m:term-langs)?"/>
        <xsl:param name="entity-flags" as="element(m:entity-flags)?"/>
        <xsl:param name="selected-type" as="element(m:type)*"/>
        <xsl:param name="active-tab" as="xs:string?"/>
        <xsl:param name="search-text" as="xs:string?"/>
        <xsl:param name="entry-label" as="element(m:label)?"/>
        
        <xsl:variable name="internal-link-path" select="tokenize($page-url, '\?')[1]"/>
        <xsl:variable name="internal-link-folder" select="tokenize($internal-link-path, '/')[last() -1]"/>
        <xsl:variable name="internal-link-attrs" select="(concat('term-lang=', $term-langs/m:lang[@selected eq 'selected'][1]/@id), $selected-type ! concat('term-type[]=', @id), concat('letter=', ''), concat('search=', $search-text), m:view-mode-parameter())" as="xs:string*"/>
        
        <div class="tabs-container-center">
            <ul class="nav nav-tabs" role="tablist">
                
                <!-- Language tabs -->
                <xsl:for-each select="$term-langs/m:lang">
                    
                    <xsl:variable name="internal-link-attrs" select="(concat('term-lang=', @id), $selected-type ! concat('term-type[]=', @id), concat('letter=', ''), concat('search=', $search-text), m:view-mode-parameter())"/>
                    
                    <li role="presentation">
                        <xsl:if test="$active-tab eq @id">
                            <xsl:attribute name="class" select="'active'"/>
                        </xsl:if>
                        <a>
                            <xsl:attribute name="href" select="common:internal-href(concat('/', $internal-link-folder, '/search.html'), $internal-link-attrs, (), $root/m:response/@lang)"/>
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
                        <xsl:attribute name="href" select="common:internal-href(concat('/', $internal-link-folder, '/downloads.html'), $internal-link-attrs, (), $root/m:response/@lang)"/>
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
                            <xsl:attribute name="href" select="common:internal-href($page-url, m:view-mode-parameter(), (), $root/m:response/@lang)"/>
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
                                <xsl:attribute name="href" select="common:internal-href(concat($internal-link-path, '?flagged=', @id), m:view-mode-parameter(), (), $root/m:response/@lang)"/>
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
                                    <xsl:attribute name="href" select="common:internal-href($page-url, m:view-mode-parameter('editor'), (), $root/m:response/@lang)"/>
                                    <xsl:attribute name="class" select="'editor'"/>
                                    <xsl:attribute name="data-loading" select="'Loading...'"/>
                                    <xsl:value-of select="'Show editor options'"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="href" select="$page-url"/>
                                    <xsl:attribute name="class" select="'editor'"/>
                                    <xsl:attribute name="data-loading" select="'Loading...'"/>
                                    <xsl:value-of select="'Hide editor options'"/>
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
        <xsl:param name="page-url" as="xs:string"/>
        
        <xsl:if test="$tei-editor and $entity">
            
            <xsl:variable name="instances-flagged" select="$entity/m:instance[m:flag]"/>
            <xsl:variable name="related-entries" select="key('related-entries', $entity/m:instance/@id, $root)"/>
            <xsl:variable name="related-entries-excluded" select="$related-entries[parent::m:text/@glossary-status eq 'excluded']"/>
            <xsl:variable name="related-entries-no-definition" select="$related-entries[not(m:definition[descendant::text()[normalize-space()]])]"/>
            <xsl:variable name="entity-definition" select="$entity/m:content[@type eq 'glossary-definition'][node()]"/>
            <xsl:variable name="related-entries-use-definition" select="if($entity-definition) then $related-entries[m:definition[@use-definition = ('both','append','prepend','override')][descendant::text()[normalize-space()]]] | $related-entries-no-definition else ()"/>
            <xsl:variable name="glossary-notes" select="$entity/m:content[@type eq 'glossary-notes'][node()]"/>
            
            <div class="well well-sm top-margin">
                
                <ul class="list-inline inline-dots">
                    
                    <li>
                        <span class="small text-muted">
                            <xsl:if test="$related-entries-use-definition">
                                <xsl:attribute name="class" select="'small text-danger'"/>
                            </xsl:if>
                            <xsl:value-of select="count($related-entries-use-definition)"/>
                            <xsl:value-of select="if (count($related-entries-use-definition) eq 1) then ' entry displays entity definition' else ' entries display entity definition'"/>
                        </span>
                    </li>
                    
                    <li>
                        <span class="small text-muted">
                            <xsl:if test="$related-entries-excluded">
                                <xsl:attribute name="class" select="'small text-danger'"/>
                            </xsl:if>
                            <xsl:value-of select="count($related-entries-excluded)"/>
                            <xsl:value-of select="if (count($related-entries-excluded) eq 1) then ' entry in an excluded text' else ' entries in excluded texts'"/>
                        </span>
                    </li>
                    
                    <li>
                        <span class="small text-muted">
                            <xsl:if test="$instances-flagged">
                                <xsl:attribute name="class" select="'small text-danger'"/>
                            </xsl:if>
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
                    </li>
                    
                    <!-- Editor link -->
                    <li>
                        <a target="84000-operations" class="editor">
                            <xsl:attribute name="href" select="concat('/edit-entity.html?entity-id=', $entity/@xml:id, '#ajax-source')"/>
                            <xsl:attribute name="data-ajax-target" select="'#popup-footer-editor .data-container'"/>
                            <xsl:attribute name="data-editor-callbackurl" select="common:internal-href(concat($reading-room-path, $page-url), m:view-mode-parameter('editor'), concat('#',$entity/@xml:id), $root/m:response/@lang)"/>
                            <xsl:value-of select="'Entity editor'"/>
                        </a>
                    </li>
                    
                </ul>
                
                <xsl:if test="$glossary-notes">
                    <hr class="sml-margin"/>
                    <h6 class="sml-margin bottom">Notes: </h6>
                    <xsl:for-each select="$glossary-notes">
                        <p class="sml-margin bottom small">
                            <xsl:value-of select="."/>
                        </p>
                    </xsl:for-each>
                </xsl:if>
                
            </div>
            
        </xsl:if>
        
    </xsl:template>
    
    <!-- Pop-up for attestation types and tei editor -->
    <xsl:template name="glossary-pop-up-footers">
        
        <!-- General pop-up -->
        <div id="popup-footer-text" class="fixed-footer collapse hidden-print">
            <div class="fix-height">
                <div class="container">
                    <div class="data-container tei-parser">
                        <!-- Ajax data here -->
                    </div>
                </div>
            </div>
            <div class="fixed-btn-container close-btn-container">
                <button type="button" class="btn-round close close-collapse" aria-label="Close">
                    <span aria-hidden="true">
                        <i class="fa fa-times"/>
                    </span>
                </button>
            </div>
        </div>
        
        <!-- Attestation types -->
        <div class="hidden hidden-print">
            <xsl:call-template name="attestation-types"/>
        </div>
        
        <!-- Pop-up for tei-editor -->
        <xsl:if test="$tei-editor">
            <xsl:call-template name="tei-editor-footer"/>
        </xsl:if>
        
    </xsl:template>
    
</xsl:stylesheet>