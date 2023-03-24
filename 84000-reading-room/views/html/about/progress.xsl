<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="about.xsl"/>
    <xsl:import href="../widget/charts.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:call-template name="about">
            
            <xsl:with-param name="sub-content">
                
                <div class="bottom-margin">
                    <xsl:call-template name="local-text">
                        <xsl:with-param name="local-key" select="'page-intro'"/>
                    </xsl:call-template>
                </div>
                
                <h2>
                    <xsl:call-template name="local-text">
                        <xsl:with-param name="local-key" select="'kangyur-summary-heading'"/>
                    </xsl:call-template>
                </h2>
                <xsl:call-template name="outline-summary">
                    <xsl:with-param name="outline-summary" select="m:outline-summary[@work eq 'UT4CZ5369']"/>
                </xsl:call-template>
                
                <xsl:call-template name="local-text">
                    <xsl:with-param name="local-key" select="'outlook'"/>
                </xsl:call-template>
                
                <h2>
                    <xsl:call-template name="local-text">
                        <xsl:with-param name="local-key" select="'combined-summary-heading'"/>
                    </xsl:call-template>
                </h2>
                <xsl:call-template name="outline-summary">
                    <xsl:with-param name="outline-summary" select="m:outline-summary"/>
                </xsl:call-template>
                
                <div id="accordion" class="list-group accordion" role="tablist" aria-multiselectable="false">
                    
                    <xsl:call-template name="expand-item">
                        <xsl:with-param name="id" select="'translations-published'"/>
                        <xsl:with-param name="accordion-selector" select="'#accordion'"/>
                        <xsl:with-param name="title-opener" select="true()"/>
                        <xsl:with-param name="title">
                            <div class="center-vertical align-left">
                                <div>
                                    <h3 class="list-group-item-heading">
                                        <xsl:call-template name="local-text">
                                            <xsl:with-param name="local-key" select="'translations-published-label'"/>
                                        </xsl:call-template>
                                    </h3>
                                </div>
                                <div>
                                    <span class="badge badge-notification">
                                        <xsl:value-of select="count(m:translations-published/m:translation-status-texts/m:text)"/>
                                    </span>
                                </div>
                            </div>
                        </xsl:with-param>
                        <xsl:with-param name="content">
                            <div class="top-margin">
                                <xsl:call-template name="text-list">
                                    <xsl:with-param name="texts" select="m:translations-published/m:translation-status-texts/m:text"/>
                                    <xsl:with-param name="list-id" select="'translations-published'"/>
                                    <xsl:with-param name="grouping" select="'text'"/>
                                </xsl:call-template>
                            </div>
                        </xsl:with-param>
                    </xsl:call-template>
                    
                    <xsl:call-template name="expand-item">
                        <xsl:with-param name="id" select="'translations-translated'"/>
                        <xsl:with-param name="accordion-selector" select="'#accordion'"/>
                        <xsl:with-param name="title-opener" select="true()"/>
                        <xsl:with-param name="title">
                            <div class="center-vertical align-left">
                                <div>
                                    <h3 class="list-group-item-heading">
                                        <xsl:call-template name="local-text">
                                            <xsl:with-param name="local-key" select="'translations-awaiting-label'"/>
                                        </xsl:call-template>
                                    </h3>
                                </div>
                                <div>
                                    <span class="badge badge-notification">
                                        <xsl:value-of select="count(m:translations-translated/m:translation-status-texts/m:text)"/>
                                    </span>
                                </div>
                            </div>
                        </xsl:with-param>
                        <xsl:with-param name="content">
                            <div class="top-margin">
                                <xsl:call-template name="text-list">
                                    <xsl:with-param name="texts" select="m:translations-translated/m:translation-status-texts/m:text"/>
                                    <xsl:with-param name="list-id" select="'translations-translated'"/>
                                    <xsl:with-param name="grouping" select="'text'"/>
                                </xsl:call-template>
                            </div>
                        </xsl:with-param>
                    </xsl:call-template>
                    
                    <xsl:call-template name="expand-item">
                        <xsl:with-param name="id" select="'translations-in-translation'"/>
                        <xsl:with-param name="accordion-selector" select="'#accordion'"/>
                        <xsl:with-param name="title-opener" select="true()"/>
                        <xsl:with-param name="title">
                            <div class="center-vertical align-left">
                                <div>
                                    <h3 class="list-group-item-heading">
                                        <xsl:call-template name="local-text">
                                            <xsl:with-param name="local-key" select="'translations-remaining-label'"/>
                                        </xsl:call-template>
                                    </h3>
                                </div>
                                <div>
                                    <span class="badge badge-notification">
                                        <xsl:value-of select="count(m:translations-in-translation/m:translation-status-texts/m:text)"/>
                                    </span>
                                </div>
                            </div>
                        </xsl:with-param>
                        <xsl:with-param name="content">
                            <div class="top-margin">
                                <xsl:call-template name="text-list">
                                    <xsl:with-param name="texts" select="m:translations-in-translation/m:translation-status-texts/m:text"/>
                                    <xsl:with-param name="list-id" select="'translations-in-translation'"/>
                                    <xsl:with-param name="grouping" select="'text'"/>
                                </xsl:call-template>
                            </div>
                        </xsl:with-param>
                    </xsl:call-template>
                    
                </div>
                
                <xsl:call-template name="local-text">
                    <xsl:with-param name="local-key" select="'related-pages'"/>
                </xsl:call-template>
                
            </xsl:with-param>
            
            <xsl:with-param name="side-content">
                <xsl:variable name="nav-sidebar">
                    <m:nav-sidebar>
                        <xsl:copy-of select="$eft-header/m:navigation[@xml:lang eq $lang]/m:item/m:item[m:item[@url eq $active-url]]"/>
                    </m:nav-sidebar>
                </xsl:variable>
                <div class="nav-sidebar">
                    <xsl:apply-templates select="$nav-sidebar"/>
                </div>
            </xsl:with-param>
            
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template name="outline-summary">
        
        <xsl:param name="outline-summary" as="element(m:outline-summary)*" required="yes"/>
        
        <div class="row about-stats">
            <div class="col-sm-6 col-lg-8">
                
                <xsl:variable name="total-pages" select="sum($outline-summary/m:tohs/m:pages/@count ! xs:integer(.))"/>
                <xsl:variable name="published-pages" select="sum($outline-summary/m:tohs/m:pages/@published ! xs:integer(.))"/>
                <xsl:variable name="translated-pages" select="sum($outline-summary/m:tohs/m:pages/@translated ! xs:integer(.))"/>
                <xsl:variable name="in-translation-pages" select="sum($outline-summary/m:tohs/m:pages/@in-translation ! xs:integer(.))"/>
                
                <xsl:call-template name="headline-stat">
                    <xsl:with-param name="colour-class" select="'blue'"/>
                    <xsl:with-param name="label-text">
                        <xsl:call-template name="local-text">
                            <xsl:with-param name="local-key" select="'translations-published-label'"/>
                        </xsl:call-template>
                    </xsl:with-param>
                    <xsl:with-param name="pages-value" select="$published-pages"/>
                    <xsl:with-param name="texts-value" select="sum($outline-summary/m:tohs/@published ! xs:integer(.))"/>
                    <xsl:with-param name="percentage-value" select="xs:integer(($published-pages div $total-pages) * 100)"/>
                </xsl:call-template>
                
                <xsl:call-template name="headline-stat">
                    <xsl:with-param name="colour-class" select="'orange'"/>
                    <xsl:with-param name="label-text">
                        <xsl:call-template name="local-text">
                            <xsl:with-param name="local-key" select="'translations-awaiting-label'"/>
                        </xsl:call-template>
                    </xsl:with-param>
                    <xsl:with-param name="pages-value" select="$translated-pages"/>
                    <xsl:with-param name="texts-value" select="sum($outline-summary/m:tohs/@translated ! xs:integer(.))"/>
                    <xsl:with-param name="percentage-value" select="xs:integer(($translated-pages div $total-pages) * 100)"/>
                </xsl:call-template>
                
                <xsl:call-template name="headline-stat">
                    <xsl:with-param name="colour-class" select="'red'"/>
                    <xsl:with-param name="label-text">
                        <xsl:call-template name="local-text">
                            <xsl:with-param name="local-key" select="'translations-remaining-label'"/>
                        </xsl:call-template>
                    </xsl:with-param>
                    <xsl:with-param name="pages-value" select="$in-translation-pages"/>
                    <xsl:with-param name="texts-value" select="sum($outline-summary/m:tohs/@in-translation ! xs:integer(.))"/>
                    <xsl:with-param name="percentage-value" select="xs:integer(($in-translation-pages div $total-pages) * 100)"/>
                </xsl:call-template>
                
            </div>
            <div class="col-sm-6 col-lg-4">
                
                <xsl:call-template name="progress-pie-chart">
                    <xsl:with-param name="outline-summary" select="$outline-summary"/>
                    <xsl:with-param name="replace-text" select="/m:response/m:replace-text"/>
                    <xsl:with-param name="show-legend" select="false()"/>
                </xsl:call-template>
                
            </div>
        </div>
        
    </xsl:template>
    
    <xsl:template name="headline-stat">
        <xsl:param name="colour-class" required="yes" as="xs:string"/>
        <xsl:param name="label-text" required="yes" as="xs:string"/>
        <xsl:param name="pages-value" as="xs:integer" select="0"/>
        <xsl:param name="texts-value" as="xs:integer" select="0"/>
        <xsl:param name="percentage-value" as="xs:double" select="0"/>
        <div>
            <xsl:attribute name="class" select="concat('stat ', $colour-class)"/>
            <div class="heading">
                <xsl:value-of select="$label-text"/>
            </div>
            <div class="data">
                <span>
                    <xsl:value-of select="format-number($pages-value, '#,###')"/>
                </span> 
                <xsl:value-of select="' '"/>
                <xsl:call-template name="local-text">
                    <xsl:with-param name="local-key" select="'pages-label'"/>
                </xsl:call-template>
                <xsl:value-of select="', '"/>
                <span>
                    <xsl:value-of select="format-number($texts-value, '#,###')"/>
                </span>
                <xsl:value-of select="' '"/>
                <xsl:call-template name="local-text">
                    <xsl:with-param name="local-key" select="'texts-label'"/>
                </xsl:call-template>
                <xsl:value-of select="', '"/>
                <span>
                    <xsl:value-of select="format-number($percentage-value, '###,##0')"/>
                    <xsl:value-of select="'%'"/>
                </span>
                <xsl:value-of select="' '"/>
                <xsl:call-template name="local-text">
                    <xsl:with-param name="local-key" select="'context-label'"/>
                </xsl:call-template>
            </div>
        </div>
    </xsl:template>
    
</xsl:stylesheet>