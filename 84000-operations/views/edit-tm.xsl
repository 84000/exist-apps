<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:bcrdb="http://www.bcrdb.org/ns/1.0" xmlns:tmx="http://www.lisa.org/tmx14" xmlns:m="http://read.84000.co/ns/1.0" xmlns:ops="http://operations.84000.co" xmlns:functx="http://www.functx.com" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/xslt/webpage.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:variable name="translation" select="/m:response/m:translation" as="element(m:translation)*"/>
    <xsl:variable name="tm-units" select="/m:response/tmx:tmx/tmx:body/tmx:tu" as="element(tmx:tu)*"/>
    <xsl:variable name="tm-units-aligned" select="/m:response/m:tm-units-aligned/m:tm-unit-aligned" as="element(m:tm-unit-aligned)*"/>
    <xsl:variable name="tei-remainder" select="/m:response/m:tm-units-aligned/m:remainder/text()" as="text()*"/>

    <xsl:variable name="first-issue-index" select="min($tm-units-aligned[@issue]/@index ! xs:integer(.))"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            <xsl:call-template name="operations-page">
                
                <xsl:with-param name="active-tab" select="@model"/>
                
                <xsl:with-param name="tab-content">
                    
                    <!-- Page title -->
                    <h3 class="visible-print-block no-top-margin">
                        <xsl:value-of select="'Translation Memory Editor'"/>
                    </h3>
                    
                    <!-- Text title -->
                    <div class="h4">
                        
                        <a>
                            <xsl:if test="$translation[m:toh]">
                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', $translation/m:toh[1]/@key, '.html?view-mode=editor')"/>
                                <xsl:attribute name="target" select="$translation/@id"/>
                                <xsl:value-of select="$translation/m:toh[1]/m:full/data()"/>
                                <xsl:value-of select="' / '"/>
                            </xsl:if>
                            <xsl:value-of select="common:limit-str($translation/m:titles/m:title[@xml:lang eq 'en'][1], 80)"/>
                        </a>
                        
                        <small>
                            <xsl:value-of select="' / '"/>
                        </small>
                        
                        <a class="small underline">
                            <xsl:attribute name="target" select="'check-folios'"/>
                            <xsl:attribute name="href" select="concat($reading-room-path, '/source/', $translation/m:toh[1]/@key, '.html?page=1')"/>
                            <xsl:attribute name="data-dualview-href" select="concat($reading-room-path, '/source/', $translation/m:toh[1]/@key, '.html?page=1')"/>
                            <xsl:attribute name="data-dualview-title" select="'Tibetan source'"/>
                            <xsl:value-of select="'Tibetan source'"/>
                        </a>
                        
                        <small>
                            <xsl:value-of select="' / '"/>
                        </small>
                        
                        <a target="_self" class="small underline" data-loading="Loading...">
                            <xsl:attribute name="href" select="concat('edit-text-header.html?id=', $translation/@id)"/>
                            <xsl:value-of select="'Edit headers'"/>
                        </a>
                        
                        <div class="pull-right">
                            <xsl:sequence select="ops:translation-status($translation/@status-group)"/>
                        </div>
                        
                    </div>
                    
                    <!-- Alert completed -->
                    <xsl:if test="not($first-issue-index) and not($tei-remainder)">
                        <div class="alert alert-success onload-scroll-target">
                            <p>
                                <xsl:value-of select="'All done! TM matches TEI'"/>
                            </p>
                        </div>
                    </xsl:if>
                    
                    <!-- Fixes -->
                    <xsl:choose>
                        
                        <!-- Fix ids -->
                        <xsl:when test="$tm-units[not(@id)]">
                            <div class="alert alert-danger small" id="alert-ids-missing">
                                <p>
                                    <xsl:value-of select="'Some IDs are missing from this TMX | '"/>
                                    <a href="{concat('/edit-tm.html?text-id=', $translation/@id, '&amp;form-action=fix-ids')}" class="alert-link">
                                        <xsl:value-of select="'Fix missing IDs'"/>
                                    </a>
                                </p>
                            </div>
                        </xsl:when>
                        
                        <!-- Fix issues -->
                        <xsl:when test="$tm-units-aligned[@issue]">
                            
                            <!-- Fix revisions -->
                            <xsl:if test="$tm-units-aligned[@issue = ('en-revised', 'new-location')]">
                                <div class="alert alert-warning small clearfix" id="alert-revisions">
                                    <p>
                                        <xsl:value-of select="'This translations contains revisions that can be automatically applied to the Translation Memory'"/>
                                    </p>
                                    <ul>
                                        <xsl:if test="$tm-units-aligned[@issue = ('en-revised')]">
                                            <li>
                                                <xsl:value-of select="concat(count($tm-units-aligned[@issue = ('en-revised')]), ' revised translation(s)')"/>
                                            </li>
                                        </xsl:if>
                                        <xsl:if test="$tm-units-aligned[@issue = ('new-location')]">
                                            <li>
                                                <xsl:value-of select="concat(count($tm-units-aligned[@issue = ('new-location')]), ' revised location(s)')"/>
                                            </li>
                                        </xsl:if>
                                    </ul>
                                    <div class="center-vertical align-left sml-margin top">
                                        <div>
                                            <a href="{concat('/edit-tm.html?text-id=', $translation/@id, '&amp;form-action=apply-revisions')}" class="btn btn-sm btn-warning">
                                                <xsl:value-of select="'Apply revisions'"/>
                                            </a>
                                        </div>
                                        <div>
                                            <a class="alert-link underline small" href="{concat('#row-', min($tm-units-aligned[@issue = ('en-revised', 'new-location')]/@index ! xs:integer(.)))}">
                                                <xsl:value-of select="'Go to first'"/>
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            </xsl:if>
                            
                            <!-- Fix unmatched -->
                            <xsl:if test="$tm-units-aligned[@issue = ('en-missing', 'en-unmatched')]">
                                <div class="alert alert-danger small clearfix" id="alert-unmatched">
                                    <p>
                                        <xsl:value-of select="'This translations contains issues that cannot be automatically resolved'"/>
                                    </p>
                                    <ul>
                                        <xsl:if test="$tm-units-aligned[@issue = ('en-missing')]">
                                            <li>
                                                <xsl:value-of select="concat(count($tm-units-aligned[@issue = ('en-missing')]), ' have no English')"/>
                                            </li>
                                        </xsl:if>
                                        <xsl:if test="$tm-units-aligned[@issue = ('en-unmatched')]">
                                            <li>
                                                <xsl:value-of select="concat(count($tm-units-aligned[@issue = ('en-unmatched')]), ' where the English is not matching the TEI')"/>
                                            </li>
                                        </xsl:if>
                                    </ul>
                                    <div class="center-vertical align-left sml-margin top">
                                        <div>
                                            <a class="alert-link underline" href="{concat('#row-', min($tm-units-aligned[@issue = ('en-missing', 'en-unmatched')]/@index ! xs:integer(.)))}">
                                                <xsl:value-of select="'Go to first'"/>
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            </xsl:if>
                            
                        </xsl:when>
                        
                        <!-- Fix remainder -->
                        <xsl:when test="$tei-remainder">
                            <div class="alert alert-warning small clearfix" id="alert-remainder">
                                <p>
                                    <xsl:value-of select="'There is English text that is not included in a TM unit'"/>
                                </p>
                                <div class="center-vertical align-left sml-margin top">
                                    <div>
                                        <a class="alert-link underline" href="{concat('#row-', max($tm-units-aligned/@index ! xs:integer(.)))}">
                                            <xsl:value-of select="'Go to remainder'"/>
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </xsl:when>
                        
                    </xsl:choose>
                    
                    <div class="div-list">
                        
                        <xsl:for-each select="$tm-units-aligned | $tei-remainder">
                            
                            <xsl:variable name="tm-unit-aligned" select="self::m:tm-unit-aligned" as="element(m:tm-unit-aligned)?"/>
                            <xsl:variable name="tm-unit" select="$tm-units[@id eq $tm-unit-aligned/@id]" as="element(tmx:tu)?"/>
                            <xsl:variable name="tm-bo" select="$tm-unit/tmx:tuv[@xml:lang eq 'bo']/tmx:seg/text()" as="text()?"/>
                            <xsl:variable name="tm-en" select="$tm-unit/tmx:tuv[@xml:lang eq 'en']/tmx:seg/text()" as="text()?"/>
                            <xsl:variable name="row-id" select="concat('row-', ($tm-unit-aligned/@index, 'new')[1])" as="xs:string"/>
                            
                            <!--<xsl:variable name="active-record" select="if($tm-unit-aligned[@index ! xs:integer(.) eq $first-issue-index]) then true() else false()" as="xs:boolean"/>-->
                            
                            <div class="item">
                                <div class="row">
                                    
                                    <xsl:attribute name="id" select="$row-id"/>
                                    
                                    <!-- Number column -->
                                    <div class="col-sm-1">
                                        
                                        <xsl:choose>
                                            <xsl:when test="$tm-unit-aligned">
                                                
                                                <span class="number">
                                                    <xsl:value-of select="$tm-unit-aligned/@index"/>
                                                </span>
                                                
                                                <xsl:if test="$tm-unit-aligned[@issue = ('en-missing','en-unmatched','en-revised','new-location')]">
                                                    
                                                    <xsl:if test="$tm-unit-aligned[@issue eq 'en-missing']">
                                                        <br/>
                                                        <span class="label label-danger">
                                                            <xsl:value-of select="'No English'"/>
                                                        </span>
                                                    </xsl:if>
                                                    
                                                    <xsl:if test="$tm-unit-aligned[@issue eq 'en-unmatched']">
                                                        <br/>
                                                        <span class="label label-danger">
                                                            <xsl:value-of select="'Not matched'"/>
                                                        </span>
                                                    </xsl:if>
                                                    
                                                    <xsl:if test="$tm-unit-aligned[@issue eq 'en-revised']">
                                                        <br/>
                                                        <span class="label label-warning">
                                                            <xsl:value-of select="'Revised'"/>
                                                        </span>
                                                    </xsl:if>
                                                    
                                                    <xsl:if test="$tm-unit-aligned[@issue eq 'new-location']">
                                                        <br/>
                                                        <span class="label label-warning">
                                                            <xsl:value-of select="'New location'"/>
                                                        </span>
                                                    </xsl:if>
                                                    
                                                    <xsl:variable name="next-issue" select="$tm-unit-aligned/following-sibling::m:tm-unit-aligned[@issue][1]"/>
                                                    <xsl:if test="$next-issue">
                                                        <br/>
                                                        <a href="{ concat('#row-', $next-issue/@index) }" class="small underline">
                                                            <xsl:value-of select="'Next issue'"/>
                                                        </a>
                                                    </xsl:if>
                                                    
                                                </xsl:if>
                                                
                                            </xsl:when>
                                            <xsl:otherwise>
                                                
                                                <span class="number">
                                                    <xsl:value-of select="max($tm-units-aligned/@index ! xs:integer(.)) + 1"/>
                                                </span>
                                                <br/>
                                                <span class="label label-warning">
                                                    <xsl:value-of select="'Remainder'"/>
                                                </span>
                                                
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        
                                    </div>
                                    
                                    <!-- Form column -->
                                    <div class="col-sm-11">
                                        
                                        <xsl:variable name="update-form-id" select="concat('form-update-segment-', $row-id)"/>
                                        
                                        <form method="post" class="form form-update stealth" id="{ $update-form-id }">
                                            
                                            <xsl:attribute name="action" select="concat('/edit-tm.html?text-id=', $translation/@id)"/>
                                            <xsl:attribute name="data-loading" select="'Updating translation memory...'"/>
                                            
                                            <!--<xsl:if test="$active-record">
                                                <xsl:attribute name="class" select="'form form-update stealth reveal onload-scroll-target'"/>
                                            </xsl:if>-->
                                            
                                            <xsl:choose>
                                                
                                                <!-- Existing unit -->
                                                <xsl:when test="$tm-bo gt ''">
                                                    
                                                    <!-- Action -->
                                                    <input type="hidden" name="form-action" value="update-segment"/>
                                                    <input type="hidden" name="tu-id" value="{ $tm-unit-aligned/@id }"/>
                                                    
                                                    <!-- Tibetan -->
                                                    <div class="form-group">
                                                        
                                                        <label for="tm-en-{ $tm-unit-aligned/@id }" class="text-muted small sml-margin bottom">
                                                            <xsl:value-of select="'Add a line break to split a segment'"/>
                                                        </label>
                                                        
                                                        <textarea name="tm-bo" id="tm-bo-new" class="form-control text-bo onkeypress-ctrlreturn-submit" placeholder="Tibetan segment">
                                                            <xsl:attribute name="rows" select="ops:textarea-rows($tm-bo, 1, 250)"/>
                                                            <xsl:value-of select="normalize-space($tm-bo)"/>
                                                        </textarea>
                                                        
                                                    </div>
                                                    
                                                    <!-- Translation -->
                                                    <xsl:choose>
                                                        
                                                        <!-- Revision to apply -->
                                                        <xsl:when test="$tm-unit-aligned[@issue eq 'en-revised']">
                                                            
                                                            <!-- Add the revision to the input -->
                                                            <div class="form-group">
                                                                
                                                                <label for="tm-en-{ $tm-unit-aligned/@id }" class="text-warning small sml-margin bottom">
                                                                    <xsl:value-of select="'Revised TEI (update to accept revision)'"/>
                                                                </label>
                                                                
                                                                <textarea name="tm-en" id="tm-en-{ $tm-unit-aligned/@id }">
                                                                    
                                                                    <xsl:attribute name="rows" select="ops:textarea-rows($tm-en, 1, 116)"/>
                                                                    
                                                                    <!--<xsl:if test="$active-record">
                                                                        <xsl:attribute name="data-onload-get-focus" select="string-length($tm-en)"/>
                                                                    </xsl:if>-->
                                                                    
                                                                    <xsl:attribute name="class" select="'form-control monospace onkeypress-ctrlreturn-submit text-warning'"/>
                                                                    
                                                                    <xsl:value-of select="$tm-unit-aligned/m:revision"/>
                                                                    
                                                                </textarea>
                                                                
                                                            </div>
                                                            
                                                            <!-- Include the original text -->
                                                            <div class="form-group stealth-hidden">
                                                                
                                                                <label for="unrevised-{ $tm-unit-aligned/@id }" class="small sml-margin bottom top">
                                                                    <xsl:value-of select="'Existing TM'"/>
                                                                </label>
                                                                
                                                                <p for="unrevised-{ $tm-unit-aligned/@id }" class="form-control monospace line-through">
                                                                    <xsl:value-of select="normalize-space($tm-en)"/>
                                                                </p>
                                                                
                                                            </div>
                                                            
                                                        </xsl:when>
                                                        
                                                        <!-- TM segment not matched in TEI -->
                                                        <xsl:when test="$tm-unit-aligned[@issue eq 'en-unmatched']">
                                                            
                                                            <!-- Add the revision to the input -->
                                                            <div class="form-group">
                                                                
                                                                <label for="tm-en-{ $tm-unit-aligned/@id }" class="text-danger small sml-margin bottom">
                                                                    <xsl:value-of select="'Current TM segment (not matched)'"/>
                                                                </label>
                                                                
                                                                <textarea name="tm-en" id="tm-en-{ $tm-unit-aligned/@id }">
                                                                    
                                                                    <xsl:attribute name="rows" select="ops:textarea-rows($tm-en, 1, 116)"/>
                                                                    
                                                                    <!--<xsl:if test="$active-record">
                                                                        <xsl:attribute name="data-onload-get-focus" select="string-length($tm-en)"/>
                                                                    </xsl:if>-->
                                                                    
                                                                    <xsl:attribute name="class" select="'form-control monospace onkeypress-ctrlreturn-submit text-danger'"/>
                                                                    
                                                                    <xsl:value-of select="normalize-space($tm-en)"/>
                                                                    
                                                                </textarea>
                                                                
                                                            </div>
                                                            
                                                            <!-- Remaining (un-matched) TEI -->
                                                            <div class="form-group stealth-hidden">
                                                                
                                                                <label for="unmatched-{ $tm-unit-aligned/@id }" class="small sml-margin bottom top">
                                                                    <xsl:value-of select="'Copy the revised text from the TEI and paste into the field above'"/>
                                                                </label>
                                                                
                                                                <p for="unmatched-{ $tm-unit-aligned/@id }" class="form-control monospace">
                                                                    <xsl:value-of select="common:limit-str($tei-remainder, 1000)"/>
                                                                </p>
                                                                
                                                            </div>
                                                            
                                                        </xsl:when>
                                                        
                                                        <!-- No en segment -->
                                                        <xsl:when test="$tm-unit-aligned[@issue eq 'en-missing']">
                                                            
                                                            <!-- Add the revision to the input -->
                                                            <div class="form-group">
                                                                
                                                                <label for="tm-en-{ $tm-unit-aligned/@id }" class="text-danger small sml-margin bottom">
                                                                    <xsl:value-of select="'Trim the English text to match the Tibetan above'"/>
                                                                </label>
                                                                
                                                                <xsl:variable name="tei-remainder-limited" as="text()">
                                                                    <xsl:value-of select="common:limit-str($tei-remainder, 1000)"/>
                                                                </xsl:variable>
                                                                <textarea name="tm-en" id="tm-en-{ $tm-unit-aligned/@id }">
                                                                    
                                                                    <xsl:attribute name="rows" select="ops:textarea-rows($tei-remainder-limited, 1, 116)"/>
                                                                    
                                                                    <!--<xsl:if test="$active-record">
                                                                        <xsl:attribute name="data-onload-get-focus" select="string-length(tokenize($tei-remainder, '[\.!\?]”?\s+')[1]) + 2"/>
                                                                    </xsl:if>-->
                                                                    
                                                                    <xsl:attribute name="class" select="'form-control monospace onkeypress-ctrlreturn-submit text-danger'"/>
                                                                    
                                                                    <xsl:value-of select="$tei-remainder-limited"/>
                                                                    
                                                                </textarea>
                                                                
                                                            </div>
                                                            
                                                        </xsl:when>
                                                        
                                                        <!-- Existing TM matches -->
                                                        <xsl:otherwise>
                                                            
                                                            <div class="form-group">
                                                                
                                                                <label for="tm-en-{ $tm-unit-aligned/@id }" class="text-muted small sml-margin bottom">
                                                                    <xsl:value-of select="'Aligned English'"/>
                                                                </label>
                                                                
                                                                <textarea name="tm-en" id="tm-en-{ $tm-unit-aligned/@id }">
                                                                    
                                                                    <xsl:attribute name="rows" select="ops:textarea-rows($tm-en, 1, 116)"/>
                                                                    
                                                                    <!--<xsl:if test="$active-record">
                                                                        <xsl:attribute name="data-onload-get-focus" select="string-length($tm-en)"/>
                                                                    </xsl:if>-->
                                                                    
                                                                    <xsl:attribute name="class" select="'form-control monospace onkeypress-ctrlreturn-submit'"/>
                                                                    
                                                                    <xsl:value-of select="normalize-space($tm-en)"/>
                                                                    
                                                                </textarea>
                                                                
                                                            </div>
                                                            
                                                        </xsl:otherwise>
                                                        
                                                    </xsl:choose>
                                                    
                                                    <!-- Footer (Location / button) -->
                                                    <div class="form-group">
                                                        
                                                        <xsl:variable name="tm-location-id" select="$tm-unit/tmx:prop[@name eq 'location-id'][1]/string()"/>
                                                        <xsl:variable name="tei-location-id" select="($tm-unit-aligned/@new-location, $tm-location-id)[1]" as="xs:string?"/>
                                                        
                                                        <label for="tei-location-id-{ $row-id }">
                                                            
                                                            <xsl:choose>
                                                                <xsl:when test="not($tei-location-id eq $tm-location-id)">
                                                                    <xsl:attribute name="class" select="'text-warning small sml-margin bottom'"/>
                                                                    <xsl:value-of select="concat('Revised location ID (previously ', ($tm-location-id, 'empty')[. gt ''][1], ') update to accept')"/>
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    <xsl:attribute name="class" select="'text-muted small sml-margin bottom'"/>
                                                                    <xsl:value-of select="'TEI location ID'"/>
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                            
                                                        </label>
                                                        
                                                        <div class="row">
                                                            
                                                            <div class="col-sm-8">
                                                                <div class="center-vertical align-left">
                                                                    
                                                                    <div>
                                                                        <input type="text" name="tei-location-id" value="{ $tei-location-id }" id="tei-location-id-{ $row-id }" class="form-control"/>
                                                                    </div>
                                                                    
                                                                    <!-- Link to location -->
                                                                    <div>
                                                                        
                                                                        <a target="{ $translation/@id }-html">
                                                                            
                                                                            <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', $translation/m:toh[1]/@key, '.html#', $tei-location-id)"/>
                                                                            <xsl:attribute name="data-dualview-href" select="concat($reading-room-path, '/translation/', $translation/m:toh[1]/@key, '.html#', $tei-location-id)"/>
                                                                            <xsl:attribute name="data-dualview-title" select="$translation/m:toh[1]/m:full/data()"/>
                                                                            
                                                                            <span class="small">
                                                                                <xsl:value-of select="'Test location'"/>
                                                                            </span>
                                                                            
                                                                        </a>
                                                                    </div>
                                                                    
                                                                </div>
                                                                
                                                            </div>
                                                            
                                                            <!-- Button -->
                                                            <xsl:choose>
                                                                <xsl:when test="$tm-unit-aligned/@id gt ''">
                                                                    
                                                                    <div class="col-sm-2 text-right">
                                                                        
                                                                        <xsl:if test="$tm-unit-aligned/@id gt ''">
                                                                            <a role="button" class="btn btn-danger btn-sm">
                                                                                <xsl:attribute name="href" select="concat('/edit-tm.html?text-id=', $translation/@id, '&amp;remove-tu=', $tm-unit-aligned/@id)"/>
                                                                                <xsl:attribute name="data-confirm" select="'Are you sure you want to delete this item?'"/>
                                                                                <xsl:value-of select="'Delete'"/>
                                                                            </a>
                                                                        </xsl:if>
                                                                        
                                                                    </div>
                                                                    
                                                                    <div class="col-sm-2 text-right">
                                                                        
                                                                        <button type="submit" class="btn btn-warning btn-sm">
                                                                            <xsl:value-of select="'Update'"/>
                                                                        </button>
                                                                        
                                                                    </div>
                                                                    
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    
                                                                    <div class="col-sm-4 text-right">
                                                                        
                                                                        <a href="#alert-ids-missing" class="small text-danger">
                                                                            <i class="fa fa-exclamation-circle" aria-hidden="true"/>
                                                                            <xsl:value-of select="' This unit has no unique id value and therefore cannot be updated'"/>
                                                                        </a>
                                                                        
                                                                    </div>
                                                                    
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                            
                                                        </div>
                                                        
                                                    </div>
                                                    
                                                </xsl:when>
                                                
                                                <!-- New unit -->
                                                <xsl:otherwise>
                                                    
                                                    <!-- Action -->
                                                    <input type="hidden" name="form-action" value="add-unit"/>
                                                    
                                                    <!-- Tibetan -->
                                                    <div class="form-group">
                                                        
                                                        <label for="tm-bo-new" class="text-muted small sml-margin bottom">
                                                            <xsl:value-of select="'Add a Tibetan segment'"/>
                                                        </label>
                                                        
                                                        <textarea name="tm-bo" id="tm-bo-new" class="form-control text-bo" placeholder="Tibetan segment">
                                                            <xsl:attribute name="rows" select="1"/>
                                                        </textarea>
                                                        
                                                    </div>
                                                    
                                                    <!-- Translation -->
                                                    <div class="form-group">
                                                        
                                                        <label for="tm-en-new" class="text-muted small sml-margin bottom">
                                                            <xsl:value-of select="'Insert a line break to segment the passage'"/>
                                                        </label>
                                                        
                                                        <xsl:variable name="tei-remainder-limited" as="text()">
                                                            <xsl:value-of select="common:limit-str($tei-remainder, 1000)"/>
                                                        </xsl:variable>
                                                        <textarea name="tm-en" id="tm-en-new" class="form-control monospace onkeypress-ctrlreturn-submit">
                                                            <xsl:attribute name="rows" select="ops:textarea-rows($tei-remainder-limited, 1, 116)"/>
                                                            <!--<xsl:attribute name="data-onload-get-focus" select="string-length(tokenize($tm-en, '[\.!\?]”?\s+')[1]) + 2"/>-->
                                                            <xsl:value-of select="$tei-remainder-limited"/>
                                                        </textarea>
                                                        
                                                    </div>
                                                    
                                                    
                                                    <!-- Button -->
                                                    <div class="form-group">
                                                        
                                                        <button type="submit" class="btn btn-warning btn-sm pull-right">
                                                            <xsl:value-of select="'Update'"/>
                                                        </button>
                                                        
                                                    </div>
                                                    
                                                </xsl:otherwise>
                                                
                                            </xsl:choose>
                                            
                                        </form>
                                        
                                    </div>
                                    
                                </div>
                            </div>
                            
                        </xsl:for-each>
                    
                    </div>
                            
                </xsl:with-param>
                <xsl:with-param name="aside-content">
                    
                    <!-- Dual-view pop-up -->
                    <xsl:call-template name="dualview-popup"/>
                    
                </xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Translation Memory Editor | 84000 Project Management'"/>
            <xsl:with-param name="page-description" select="'Create Translation Memory pairs from 84000 TEI files'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>