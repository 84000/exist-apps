<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="website-page.xsl"/>
    
    <xsl:template match="m:results">
        
        <!-- Some tests -->
        <xsl:choose>
            
            <xsl:when test="count(m:structure/m:test[@pass eq '0']) eq 0">
                <div class="alert alert-success small text-center">
                    <p>
                        <xsl:value-of select="'No errors were found in the sections structure.'"/>
                    </p>
                </div>
            </xsl:when>
            
            <xsl:otherwise>
                <xsl:for-each select="m:structure/m:test[@pass eq '0']">
                    <div class="alert alert-danger small">
                        
                        <p>
                            <xsl:value-of select="concat('Failed test: ', m:title)"/>
                        </p>
                        
                        <ol>
                            <xsl:for-each select="m:details/m:detail">
                                <li>
                                    <xsl:value-of select="text()"/>
                                </li>
                            </xsl:for-each>
                        </ol>
                        
                        <xsl:if test="/m:response[@model eq 'utilities/sections'][@user-name eq 'admin'] and /m:response/m:environment/m:store-conf[@type eq 'client']">
                            <xsl:choose>
                                <xsl:when test="@id eq 'unmatched-ids'">
                                    <a href="/sections.html?resolve=unmatched-ids" class="btn btn-default btn-sm" target="_self">
                                        <xsl:attribute name="data-loading" select="'Getting TEI files with unmatched @source-ids...'"/>
                                        <xsl:value-of select="'Get TEI files with unmatched @source-ids from Collaboration'"/>
                                    </a>
                                </xsl:when>
                                <xsl:when test="@id eq 'unmatched-tei'">
                                    <a href="/sections.html?resolve=unmatched-tei" class="btn btn-default btn-sm" target="_self">
                                        <xsl:attribute name="data-loading" select="'Updating TEI files with invalid @source-ids...'"/>
                                        <xsl:value-of select="'Update TEI files with invalid @source-ids from Collaboration'"/>
                                    </a>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:if>
                        
                    </div>
                </xsl:for-each>
            </xsl:otherwise>
            
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template match="m:section">
        
        <table class="table table-responsive">
            <thead>
                <tr>
                    <th>Section</th>
                    <th/>
                    <th class="small nowrap">Total</th>
                    <th class="small nowrap">Published</th>
                    <!--<th class="small nowrap">In-progress</th>-->
                    <th class="small nowrap">Translated</th>
                    <th class="small nowrap">In-translation</th>
                    <th class="small nowrap">Not started</th>
                </tr>
            </thead>
            <tbody>
                <xsl:for-each select="m:section">
                    <xsl:sort select="xs:integer(@sort-index)"/>
                    <xsl:call-template name="section-row"/>
                </xsl:for-each>
            </tbody>
        </table>
        
    </xsl:template>
    
    <xsl:template name="section-row">
        
        <xsl:variable name="section-texts-id" select="concat('section-texts-', fn:encode-for-uri(@id))"/>
        
        <xsl:variable name="count-text-descendants" select="m:text-stats/m:stat[@type eq 'count-text-descendants']/@value ! xs:integer(.)"/>
        <xsl:variable name="sum-pages-text-descendants" select="m:text-stats/m:stat[@type eq 'sum-pages-text-descendants']/@value ! xs:integer(.)"/>
        
        <xsl:variable name="count-text-children" select="m:text-stats/m:stat[@type eq 'count-text-children']/@value ! xs:integer(.)"/>
        <xsl:variable name="sum-pages-text-children" select="m:text-stats/m:stat[@type eq 'sum-pages-text-children']/@value ! xs:integer(.)"/>
        
        <tr>
            
            <td>
                
                <xsl:if test="m:section">
                    <xsl:attribute name="rowspan" select="'2'"/>
                </xsl:if>
                
                <xsl:call-template name="indent">
                    <xsl:with-param name="counter" select="1"/>
                    <xsl:with-param name="finish" select="xs:integer(@nesting)"/>
                    <xsl:with-param name="content">
                        <div>
                            <span class="text-bold">
                                <xsl:value-of select="m:titles/m:title[@xml:lang eq 'en']"/>
                            </span>
                            <small>
                                <xsl:value-of select="concat(' \ ', @id)"/>
                            </small>
                        </div>
                        <div class="sml-margin bottom">
                            <ul class="list-inline inline-dots">
                                <li>
                                    <a>
                                        <xsl:attribute name="href" select="concat($reading-room-path ,'/section/', @id, '.tei')"/>
                                        <xsl:attribute name="target" select="concat(@id, '.tei')"/>
                                        <span class="small">
                                            <xsl:value-of select="'tei'"/>
                                        </span>
                                    </a>
                                </li>
                                <li>
                                    <a>
                                        <xsl:attribute name="href" select="concat($reading-room-path ,'/section/', @id, '.xml')"/>
                                        <xsl:attribute name="target" select="concat(@id, '.xml')"/>
                                        <span class="small">
                                            <xsl:value-of select="'xml'"/>
                                        </span>
                                    </a>
                                </li>
                                <li>
                                    <a>
                                        <xsl:attribute name="href" select="concat($reading-room-path ,'/section/', @id, '.json')"/>
                                        <xsl:attribute name="target" select="concat(@id, '.json')"/>
                                        <span class="small">
                                            <xsl:value-of select="'json'"/>
                                        </span>
                                    </a>
                                </li>
                                <li>
                                    <a>
                                        <xsl:attribute name="href" select="concat($reading-room-path ,'/section/', @id, '.html')"/>
                                        <xsl:attribute name="target" select="concat(@id, '.html')"/>
                                        <span class="small">
                                            <xsl:value-of select="'html'"/>
                                        </span>
                                    </a>
                                </li>
                                <li>
                                    <a>
                                        <xsl:attribute name="href" select="concat($reading-room-path ,'/section/', @id, '.navigation.atom')"/>
                                        <xsl:attribute name="target" select="concat(@id, '.navigation.atom')"/>
                                        <span class="small">
                                            <xsl:value-of select="'navigation.atom'"/>
                                        </span>
                                    </a>
                                </li>
                                <xsl:if test="xs:integer(m:text-stats/m:stat[@type eq 'count-published-children']/@value) gt 0">
                                    <li>
                                        <a>
                                            <xsl:attribute name="href" select="concat($reading-room-path ,'/section/', @id, '.acquisition.atom')"/>
                                            <xsl:attribute name="target" select="concat(@id, '.acquisition.atom')"/>
                                            <span class="small">
                                                <xsl:value-of select="'acquisition.atom'"/>
                                            </span>
                                        </a>
                                    </li>
                                </xsl:if>
                                <li>
                                    <a>
                                        <xsl:attribute name="href" select="concat('/test-sections.html?section-id=', @id)"/>
                                        <xsl:attribute name="target" select="concat(@id, 'tests')"/>
                                        <span class="small">
                                            <xsl:value-of select="'run tests'"/>
                                        </span>
                                    </a>
                                </li>
                            </ul>
                        </div>
                        <div class="small text-muted">
                            <xsl:value-of select="'TEI file: '"/>
                            <span class="break">
                                <xsl:value-of select="@document-url"/>
                            </span>
                        </div>
                    </xsl:with-param>
                </xsl:call-template>
                
            </td>
            
            <th class="small nowrap text-warning">this section:</th>
            
            <!-- Count of texts / pages -->
            <td class="small">
                <a href="#" target="_self">
                    <xsl:choose>
                        <xsl:when test="$count-text-children gt 0">
                            <xsl:attribute name="href" select="concat('section-texts.html?section-id=', fn:encode-for-uri(@id), '#ajax-source')"/>
                            <xsl:attribute name="data-ajax-target" select="concat('#', $section-texts-id, ' .ajax-target')"/>
                            <xsl:attribute name="aria-controls" select="$section-texts-id"/>
                            <xsl:attribute name="class" select="'underline'"/>
                            <span class="nowrap">
                                <xsl:value-of select="fn:format-number($count-text-children,'#,##0')"/>
                                <span class="text-muted">
                                    <xsl:value-of select="' texts'"/>
                                </span>
                            </span>
                            <br/>
                            <span class="nowrap">
                                <xsl:value-of select="fn:format-number($sum-pages-text-children,'#,##0')"/>
                                <span class="text-muted">
                                    <xsl:value-of select="' pages'"/>
                                </span>
                            </span>
                        </xsl:when>
                        <xsl:otherwise>-</xsl:otherwise>
                    </xsl:choose>
                </a>
                <!-- Alert user if un-matched texts found -->
                <xsl:choose>
                    <xsl:when test="/m:response/m:results/m:structure/m:test[@id eq 'unmatched-section-texts']//*[@ref eq $section-texts-id]">
                        <span>
                            <xsl:attribute name="class" select="'label label-danger'"/>
                            <xsl:attribute name="title" select="/m:response/m:results/m:structure/m:test[@id eq 'unmatched-section-texts']//*[@ref eq $section-texts-id]/text()"/>
                            <xsl:value-of select="'error'"/>
                        </span>
                    </xsl:when>
                </xsl:choose>
            </td>
            
            <!-- Published -->
            <td class="small">
                <xsl:call-template name="section-stat">
                    <xsl:with-param name="show-stat" select="$count-text-children gt 0"/>
                    <xsl:with-param name="text-count" select="xs:integer(m:text-stats/m:stat[@type eq 'count-published-children']/@value)"/>
                    <xsl:with-param name="page-count" select="xs:integer(m:text-stats/m:stat[@type eq 'sum-pages-published-children']/@value)"/>
                    <xsl:with-param name="page-total" select="$sum-pages-text-children"/>
                </xsl:call-template>
            </td>
            
            <!-- Translated -->
            <td class="small">
                <xsl:call-template name="section-stat">
                    <xsl:with-param name="show-stat" select="$count-text-children gt 0"/>
                    <xsl:with-param name="text-count" select="xs:integer(m:text-stats/m:stat[@type eq 'count-translated-children']/@value)"/>
                    <xsl:with-param name="page-count" select="xs:integer(m:text-stats/m:stat[@type eq 'sum-pages-translated-children']/@value)"/>
                    <xsl:with-param name="page-total" select="$sum-pages-text-children"/>
                </xsl:call-template>
            </td>
            
            <!-- In-translation -->
            <td class="small">
                <xsl:call-template name="section-stat">
                    <xsl:with-param name="show-stat" select="$count-text-children gt 0"/>
                    <xsl:with-param name="text-count" select="xs:integer(m:text-stats/m:stat[@type eq 'count-in-translation-children']/@value)"/>
                    <xsl:with-param name="page-count" select="xs:integer(m:text-stats/m:stat[@type eq 'sum-pages-in-translation-children']/@value)"/>
                    <xsl:with-param name="page-total" select="$sum-pages-text-children"/>
                </xsl:call-template>
            </td>
            
            <!-- Not-started -->
            <td class="small">
                <xsl:variable name="texts-not-started" select="$count-text-children - sum(m:text-stats/m:stat[@type = ('count-published-children','count-translated-children','count-in-translation-children')]/@value ! xs:integer(.))"/>
                <xsl:variable name="pages-not-started" select="$sum-pages-text-children - sum(m:text-stats/m:stat[@type = ('sum-pages-published-children','sum-pages-translated-children','sum-pages-in-translation-children')]/@value ! xs:integer(.))"/>
                <xsl:call-template name="section-stat">
                    <xsl:with-param name="show-stat" select="$count-text-children gt 0"/>
                    <xsl:with-param name="text-count" select="xs:integer($texts-not-started)"/>
                    <xsl:with-param name="page-count" select="xs:integer($pages-not-started)"/>
                    <xsl:with-param name="page-total" select="$sum-pages-text-children"/>
                </xsl:call-template>
            </td>
            
        </tr>
        
        <xsl:if test="m:section">
            
            <tr>
                
                <th class="small nowrap text-warning">+ sub-sections:</th>
                
                <!-- Count of texts / pages -->
                <td class="small">
                    <xsl:choose>
                        <xsl:when test="$count-text-descendants gt $count-text-children">
                            <span class="nowrap">
                                <xsl:value-of select="fn:format-number($count-text-descendants,'#,##0')"/>
                                <span class="text-muted">
                                    <xsl:value-of select="' texts'"/>
                                </span>
                            </span>
                            <br/>
                            <span class="nowrap">
                                <xsl:value-of select="fn:format-number($sum-pages-text-descendants,'#,##0')"/>
                                <span class="text-muted">
                                    <xsl:value-of select="' pages'"/>
                                </span>
                            </span>
                        </xsl:when>
                        <xsl:otherwise>-</xsl:otherwise>
                    </xsl:choose>
                </td>
                
                <!-- Published -->
                <td class="small">
                    <xsl:call-template name="section-stat">
                        <xsl:with-param name="show-stat" select="$count-text-descendants gt $count-text-children"/>
                        <xsl:with-param name="text-count" select="xs:integer(m:text-stats/m:stat[@type eq 'count-published-descendants']/@value)"/>
                        <xsl:with-param name="page-count" select="xs:integer(m:text-stats/m:stat[@type eq 'sum-pages-published-descendants']/@value)"/>
                        <xsl:with-param name="page-total" select="$sum-pages-text-descendants"/>
                    </xsl:call-template>
                </td>
                
                <!-- Translated -->
                <td class="small">
                    <xsl:call-template name="section-stat">
                        <xsl:with-param name="show-stat" select="$count-text-descendants gt $count-text-children"/>
                        <xsl:with-param name="text-count" select="xs:integer(m:text-stats/m:stat[@type eq 'count-translated-descendants']/@value)"/>
                        <xsl:with-param name="page-count" select="xs:integer(m:text-stats/m:stat[@type eq 'sum-pages-translated-descendants']/@value)"/>
                        <xsl:with-param name="page-total" select="$sum-pages-text-descendants"/>
                    </xsl:call-template>
                </td>
                
                <!-- In-translation -->
                <td class="small">
                    <xsl:call-template name="section-stat">
                        <xsl:with-param name="show-stat" select="$count-text-descendants gt $count-text-children"/>
                        <xsl:with-param name="text-count" select="xs:integer(m:text-stats/m:stat[@type eq 'count-in-translation-descendants']/@value)"/>
                        <xsl:with-param name="page-count" select="xs:integer(m:text-stats/m:stat[@type eq 'sum-pages-in-translation-descendants']/@value)"/>
                        <xsl:with-param name="page-total" select="$sum-pages-text-descendants"/>
                    </xsl:call-template>
                </td>
                
                <!-- Not-started -->
                <td class="small">
                    <xsl:variable name="texts-not-started" select="$count-text-descendants ! xs:integer(.) - sum(m:text-stats/m:stat[@type = ('count-published-descendants','count-translated-descendants','count-in-translation-descendants')]/@value ! xs:integer(.))"/>
                    <xsl:variable name="pages-not-started" select="$sum-pages-text-descendants - sum(m:text-stats/m:stat[@type = ('sum-pages-published-descendants','sum-pages-translated-descendants','sum-pages-in-translation-descendants')]/@value ! xs:integer(.))"/>
                    <xsl:call-template name="section-stat">
                        <xsl:with-param name="show-stat" select="$count-text-descendants gt $count-text-children"/>
                        <xsl:with-param name="text-count" select="xs:integer($texts-not-started)"/>
                        <xsl:with-param name="page-count" select="xs:integer($pages-not-started)"/>
                        <xsl:with-param name="page-total" select="$sum-pages-text-descendants"/>
                    </xsl:call-template>
                </td>
                
            </tr>
            
        </xsl:if>
        
        <tr class="sub">
            <td colspan="6">
                <div class="collapse">
                    <xsl:attribute name="id" select="$section-texts-id"/>
                    <div class="ajax-target"/>
                </div>
            </td>
        </tr>
        
        <xsl:for-each select="m:section">
            <xsl:sort select="xs:integer(@sort-index)"/>
            <xsl:call-template name="section-row"/>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="section-stat">
        
        <xsl:param name="show-stat" as="xs:boolean"/>
        <xsl:param name="text-count" as="xs:integer"/>
        <xsl:param name="page-count" as="xs:integer"/>
        <xsl:param name="page-total" as="xs:integer"/>
        
        <xsl:choose>
            <xsl:when test="$show-stat">
                <span class="nowrap">
                    <xsl:value-of select="fn:format-number($text-count,'#,##0')"/>
                    <span class="text-muted">
                        <xsl:value-of select="' texts'"/>
                    </span>
                </span>
                <br/>
                <span class="nowrap">
                    <xsl:value-of select="fn:format-number($page-count,'#,##0')"/>
                    <span class="text-muted">
                        <xsl:value-of select="' pages'"/>
                    </span>
                </span>
                <br/>
                <span class="nowrap">
                    <xsl:choose>
                        <xsl:when test="$page-total gt 0">
                            <xsl:value-of select="fn:format-number((($page-count div $page-total) * 100), '#,###')"/>
                            <span class="text-muted">
                                <xsl:value-of select="' %'"/>
                            </span>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'0'"/>
                            <span class="text-muted">
                                <xsl:value-of select="' %'"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </span>
            </xsl:when>
            <xsl:otherwise>-</xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
</xsl:stylesheet>