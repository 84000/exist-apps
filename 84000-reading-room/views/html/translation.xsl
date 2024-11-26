<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../xslt/tei-to-xhtml.xsl"/>

    <!-- Look up environment variables -->
    <!--<xsl:variable name="app-path" select="$environment/m:url[@id eq 'app']/text()"/>-->
    <xsl:variable name="render-status" select="$environment/m:render/m:status[@type eq 'translation']/@status-id"/>
    
    <xsl:variable name="page-title" as="node()*">
        <xsl:sequence select="$translation/m:titles/m:title[@xml:lang eq 'en']"/>
        <xsl:sequence select="$translation//m:part[@content-status eq 'complete'][@id eq $requested-part][1]/tei:head[@type eq parent::m:part/@type]"/>
    </xsl:variable>
    
    <xsl:variable name="download-files" select="$translation[@status = $render-status]/m:files/m:file[@type = ('pdf','epub')][@group eq 'translation-files'][@timestamp gt '']"/>
    
    <xsl:template match="/m:response">
        
        <!-- PAGE CONTENT -->
        <xsl:variable name="content">
            
            <!-- Un-published alert -->
            <xsl:if test="not($translation/@status-group eq 'published')">
                <div class="title-band warning">
                    <div class="container">
                        <div class="center-vertical center-aligned">
                            <div>
                                <xsl:value-of select="'This text is not yet ready for publication!'"/>
                            </div>
                        </div>                        
                    </div>
                </div>
            </xsl:if>
            
            <!-- Main article -->
            <main>
                
                <!-- Breadcrumbs -->
                <xsl:if test="$translation[m:parent]">
                    <div class="title-band hidden-print hidden-iframe">
                        <div class="container">
                            <div class="center-vertical center-aligned text-center">
                                <nav aria-label="Breadcrumbs">
                                    <ul id="outline" class="breadcrumb">
                                        <li>
                                            <a>
                                                <xsl:attribute name="href" select="'/'"/>
                                                <xsl:value-of select="'84000'"/>
                                            </a>
                                        </li>
                                        <xsl:sequence select="common:breadcrumb-items($translation/m:parent/descendant-or-self::m:parent, /m:response/@lang)"/>
                                        <li>
                                            <xsl:apply-templates select="$translation/m:source/m:toh"/>
                                        </li>
                                    </ul>
                                </nav>
                            </div>
                        </div>
                    </div>
                </xsl:if>
                
                <!-- Titles -->
                <div class="content-band content-band-gray">
                    <div class="container">
                        <xsl:call-template name="titles"/>
                    </div>
                </div>
                
                <div class="content-band">
                    <div class="container">
                        
                        <!-- Imprint -->
                        <xsl:call-template name="imprint"/>
                        
                        <!-- Table of Contents -->
                        <xsl:if test="$translation/@status = $render-status">
                            <div class="row">
                                <div class="col-md-offset-1 col-md-10 col-lg-offset-2 col-lg-8 print-width-override">
                                    <section id="toc" class="page page-force">
                                        
                                        <xsl:attribute name="data-part-type" select="'toc'"/>
                                        
                                        <xsl:call-template name="table-of-contents"/>
                                        
                                    </section>
                                </div>
                            </div>
                        </xsl:if>
                        
                        <!-- Parts -->
                        <div id="parts">
                            
                            <!-- Summary -->
                            <xsl:call-template name="part">
                                <xsl:with-param name="part" select="$translation/m:part[@type eq 'summary']"/>
                                <xsl:with-param name="css-classes" select="'page page-force text'"/>
                            </xsl:call-template>
                            
                            <xsl:if test="$translation/@status = $render-status">
                                
                                <!-- Acknowledgment -->
                                <xsl:call-template name="part">
                                    <xsl:with-param name="part" select="$translation/m:part[@type eq 'acknowledgment']"/>
                                    <xsl:with-param name="css-classes" select="'page text'"/>
                                </xsl:call-template>
                                
                                <!-- Preface -->
                                <xsl:call-template name="part">
                                    <xsl:with-param name="part" select="$translation/m:part[@type eq 'preface']"/>
                                    <xsl:with-param name="css-classes" select="'page text'"/>
                                </xsl:call-template>
                                
                                <!-- Introduction -->
                                <xsl:call-template name="part">
                                    <xsl:with-param name="part" select="$translation/m:part[@type eq 'introduction']"/>
                                    <xsl:with-param name="css-classes" select="'page text'"/>
                                </xsl:call-template>
                                
                                <!-- Prelude -->
                                <xsl:if test="$translation/m:part[@type eq 'translation']/m:part[@type eq 'prelude']">
                                    
                                    <!-- Translation title -->
                                    <xsl:call-template name="prelude-title"/>
                                    
                                    <xsl:call-template name="part">
                                        <xsl:with-param name="part" select="$translation/m:part[@type eq 'translation']/m:part[@type eq 'prelude']"/>
                                        <xsl:with-param name="css-classes" select="'text page'"/>
                                    </xsl:call-template>
                                    
                                </xsl:if>
                                
                                <!-- Translation title -->
                                <xsl:call-template name="body-title"/>
                                
                                <!-- The Chapters -->
                                <xsl:for-each select="$translation/m:part[@type eq 'translation']/m:part[not(@type eq 'prelude')]">
                                    
                                    <xsl:call-template name="part">
                                        <xsl:with-param name="part" select="."/>
                                        <xsl:with-param name="css-classes" select="'text page'"/>
                                    </xsl:call-template>
                                    
                                </xsl:for-each>
                                
                                <!-- Appendix -->
                                <xsl:call-template name="part">
                                    <xsl:with-param name="part" select="$translation/m:part[@type eq 'appendix']"/>
                                    <xsl:with-param name="css-classes" select="'page text'"/>
                                </xsl:call-template>
                                
                                <!-- Abbreviations -->
                                <xsl:call-template name="part">
                                    <xsl:with-param name="part" select="$translation/m:part[@type eq 'abbreviations']"/>
                                    <xsl:with-param name="css-classes" select="'page'"/>
                                </xsl:call-template>
                                
                                <!-- Notes -->
                                <xsl:call-template name="part">
                                    <xsl:with-param name="part" select="$translation/m:part[@type eq 'end-notes']"/>
                                    <xsl:with-param name="css-classes" select="'page'"/>
                                </xsl:call-template>
                                
                                <!-- Bilbiography -->
                                <xsl:call-template name="part">
                                    <xsl:with-param name="part" select="$translation/m:part[@type eq 'bibliography']"/>
                                    <xsl:with-param name="css-classes" select="'page'"/>
                                </xsl:call-template>
                                
                                <!-- Glossary -->
                                <xsl:call-template name="part">
                                    <xsl:with-param name="part" select="$translation/m:part[@type eq 'glossary']"/>
                                    <xsl:with-param name="css-classes" select="'page'"/>
                                </xsl:call-template>
                                
                                <!-- Citation Index -->
                                <xsl:call-template name="part">
                                    <xsl:with-param name="part" select="$translation/m:part[@type eq 'citation-index']"/>
                                    <xsl:with-param name="css-classes" select="'page'"/>
                                </xsl:call-template>
                                
                            </xsl:if>
                            
                        </div>
                        
                    </div>
                </div>
                
            </main>
            
            <!-- Additional functional elements -->
            <xsl:if test="$view-mode[@client eq 'browser'][not(@layout eq 'flat')]">
                
                <!-- Navigation controls -->
                <nav class="nav-controls show-on-scroll-xs hidden-print hidden-iframe" aria-label="Navigation icons">
                    
                    <div id="navigation-btn-container" class="fixed-btn-container">
                        <a href="#contents-sidebar" class="btn-round show-sidebar" aria-haspopup="true" title="Show the side navigation panel">
                            <i class="fa fa-bars" aria-hidden="true"/>
                        </a>
                    </div>
                    
                    <div id="bookmarks-btn-container" class="fixed-btn-container">
                        <a href="#bookmarks-sidebar" id="bookmarks-btn" class="btn-round show-sidebar" aria-haspopup="true" title="Show the bookmarks panel">
                            <i class="fa fa-bookmark"/>
                            <span class="badge badge-notification">0</span>
                        </a>
                    </div>
                    
                    <!-- Link to the start of the section / defaults to the start of the page -->
                    <div id="link-to-trans-top-container" class="fixed-btn-container">
                        <a class="btn-round link-to-top hidden" title="Go to the top of the page">
                            <xsl:attribute name="href" select="'#top'"/>
                            <i class="fa fa-arrow-up" aria-hidden="true"/>
                        </a>
                    </div>
                    
                    <div id="rewind-btn-container" class="fixed-btn-container hidden">
                        <button class="btn-round" title="Return to the previous location">
                            <i class="fa fa-undo" aria-hidden="true"/>
                        </button>
                    </div>
                    
                </nav>
                
                <!-- Dual-view pop-up -->
                <xsl:call-template name="dualview-popup"/>
                
                <!-- General pop-up for notes and glossary -->
                <div id="popup-footer-text" class="fixed-footer collapse hidden-print">
                    <div class="fix-height">
                        <div class="container">
                            <div class="row">
                                <div class="col-md-offset-1 col-md-10 col-lg-offset-2 col-lg-8">
                                    <div class="data-container tei-parser">
                                        <!-- Ajax data here -->
                                    </div>
                                </div>
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
                
                <!-- Pop-up for attestation types - an additional pop-up is required as initial will be in use for glossary  -->
                <div id="popup-footer-attestation" class="fixed-footer collapse hidden-print">
                    <div class="fix-height">
                        <div class="container">
                            <div class="row">
                                <div class="col-md-offset-1 col-md-10 col-lg-offset-2 col-lg-8">
                                    <div class="data-container tei-parser">
                                        <!-- Ajax data here -->
                                    </div>
                                </div>
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
                
                <!-- Pop-up for download dana -->
                <xsl:call-template name="popup-download-dana">
                    <xsl:with-param name="translation-title" select="$translation/m:titles/m:title[@xml:lang eq 'en']"/>
                </xsl:call-template>
                
                <!-- Contents fly-out -->
                <div id="contents-sidebar" class="fixed-sidebar collapse width hidden-print">
                    
                    <xsl:variable name="text-id" select="$translation/@id"/>
                    
                    <div class="fix-width">
                        <div class="sidebar-content">
                            
                            <!--<h3>
                                <xsl:value-of select="$translation/m:titles/m:title[text()][@xml:lang eq 'en'][1]"/>
                            </h3>-->
                            
                            <xsl:if test="$translation/@status = $render-status">
                                
                                <div id="contents-sidebar-toc">
                                    <h4>
                                        <xsl:value-of select="'Table of Contents'"/>
                                    </h4>
                                    <div class="data-container bottom-margin"/>
                                    <hr/>
                                </div>
                                
                                <div id="contents-sidebar-search-text">
                                    <h4>
                                        <xsl:value-of select="'Search this text'"/>
                                    </h4>
                                    <form action="/search.html" method="post" role="search" class="form-horizontal bottom-margin">
                                        <input type="hidden" name="specified-text" value="{ $text-id }"/>
                                        <div class="input-group">
                                            <input type="search" name="search" id="search" class="form-control" placeholder="Search" required="required" aria-label="Search text" value=""/>
                                            <span class="input-group-btn">
                                                <button type="submit" class="btn btn-primary">
                                                    <i class="fa fa-search"/>
                                                </button>
                                            </span>
                                        </div>
                                    </form>
                                    <hr/>
                                </div>
                                
                                <xsl:if test="$download-files">
                                    <div id="contents-sidebar-downloads">
                                        <h4>
                                            <xsl:value-of select="'Other ways to read'"/>
                                        </h4>
                                        <table class="contents-table bottom-margin">
                                            <tbody>
                                                
                                                <xsl:if test="$part-status eq 'complete'">
                                                    <tr>
                                                        <td>
                                                            <a target="_blank" class="print-preview">
                                                                <xsl:attribute name="title" select="'Print'"/>
                                                                <xsl:attribute name="href" select="'#'"/>
                                                                <i class="fa fa-laptop"/>
                                                            </a>
                                                        </td>
                                                        <td>
                                                            <a href="#" title="Print" class="print-preview">
                                                                <xsl:value-of select="'Print'"/>
                                                            </a>
                                                        </td>
                                                    </tr>
                                                </xsl:if>
                                                
                                                <xsl:for-each select="$download-files">
                                                    <tr>
                                                        <td class="icon">
                                                            <a target="_blank">
                                                                <xsl:attribute name="title">
                                                                    <xsl:call-template name="download-label">
                                                                        <xsl:with-param name="type" select="@type"/>
                                                                    </xsl:call-template>
                                                                </xsl:attribute>
                                                                <xsl:attribute name="href" select="@source"/>
                                                                <xsl:attribute name="download" select="@target-file"/>
                                                                <xsl:attribute name="class" select="'log-click'"/>
                                                                <xsl:attribute name="data-onclick-show" select="'#popup-footer-download-dana'"/>
                                                                <xsl:attribute name="data-log-click-text-id" select="$text-id"/>
                                                                <xsl:call-template name="download-icon">
                                                                    <xsl:with-param name="type" select="@type"/>
                                                                </xsl:call-template>
                                                            </a>
                                                        </td>
                                                        <td>
                                                            <a target="_blank">
                                                                <xsl:attribute name="title">
                                                                    <xsl:call-template name="download-label">
                                                                        <xsl:with-param name="type" select="@type"/>
                                                                    </xsl:call-template>
                                                                </xsl:attribute>
                                                                <xsl:attribute name="href" select="@source"/>
                                                                <xsl:attribute name="download" select="@target-file"/>
                                                                <xsl:attribute name="class" select="'log-click'"/>
                                                                <xsl:attribute name="data-onclick-show" select="'#popup-footer-download-dana'"/>
                                                                <xsl:attribute name="data-log-click-text-id" select="$text-id"/>
                                                                <xsl:call-template name="download-label">
                                                                    <xsl:with-param name="type" select="@type"/>
                                                                </xsl:call-template>
                                                            </a>
                                                        </td>
                                                    </tr>
                                                </xsl:for-each>
                                                
                                                <xsl:if test="$translation[@status eq '1']">
                                                    <xsl:variable name="app-href" select="concat('https://app.84000.co/translation/', $toh-key, '.html')"/>
                                                    <tr>
                                                        <td class="icon">
                                                            <a target="_blank">
                                                                <xsl:attribute name="title">
                                                                    <xsl:call-template name="download-label">
                                                                        <xsl:with-param name="type" select="'app'"/>
                                                                    </xsl:call-template>
                                                                </xsl:attribute>
                                                                <xsl:attribute name="href" select="$app-href"/>
                                                                <xsl:attribute name="class" select="'log-click'"/>
                                                                <xsl:attribute name="data-log-click-text-id" select="$text-id"/>
                                                                <xsl:attribute name="target" select="'84000-comms'"/>
                                                                <xsl:call-template name="download-icon">
                                                                    <xsl:with-param name="type" select="'app'"/>
                                                                </xsl:call-template>
                                                            </a>
                                                        </td>
                                                        <td>
                                                            <a target="_blank">
                                                                <xsl:attribute name="title">
                                                                    <xsl:call-template name="download-label">
                                                                        <xsl:with-param name="type" select="'app'"/>
                                                                    </xsl:call-template>
                                                                </xsl:attribute>
                                                                <xsl:attribute name="href" select="$app-href"/>
                                                                <xsl:attribute name="class" select="'log-click'"/>
                                                                <xsl:attribute name="data-log-click-text-id" select="$text-id"/>
                                                                <xsl:attribute name="target" select="'84000-comms'"/>
                                                                <xsl:call-template name="download-label">
                                                                    <xsl:with-param name="type" select="'app'"/>
                                                                </xsl:call-template>
                                                            </a>
                                                        </td>
                                                    </tr>
                                                </xsl:if>
                                                
                                            </tbody>
                                        </table>
                                        <hr/>
                                    </div>
                                </xsl:if>
                                
                            </xsl:if>
                            
                            <div id="contents-sidebar-contact-form">
                                <h4>
                                    <xsl:value-of select="'Spotted a mistake?'"/>
                                </h4>
                                <p class="small text-muted">
                                    <xsl:value-of select="'Please use the contact form provided to '"/>
                                    <a target="84000-comms">
                                        <xsl:attribute name="href" select="concat('https://84000.co/about/contact/?toh=', encode-for-uri($translation/m:source/m:toh[1]) ,'#suggest-a-correction-section')"/>
                                        <xsl:value-of select="'suggest a correction'"/>
                                    </a>
                                    <xsl:value-of select="'.'"/>
                                </p>
                                <hr/>
                            </div>
                            
                            <xsl:if test="$translation/@status = $render-status">
                                <div id="contents-sidebar-citation-help">
                                    <h4>
                                        <xsl:value-of select="'How to cite this text'"/>
                                    </h4>
                                    <p class="small text-muted">
                                        <xsl:value-of select="'The following are examples of how to correctly cite this publication. '"/>
                                        <xsl:value-of select="'Links to specific passages can be derived by right-clicking on the milestones markers in the left-hand margin (e.g. s.1). The copied link address can replace the url below.'"/>
                                    </p>
                                    <div class="citation-tabs">
                                        
                                        <ul class="nav nav-tabs sml-tabs" role="tablist">
                                            <li role="presentation" class="active">
                                                <a href="#eft-citation-cms" aria-controls="eft-citation-cms" role="tab" data-toggle="tab">
                                                    <xsl:attribute name="title" select="'Chicago Manual style'"/>
                                                    <xsl:value-of select="'Chicago'"/>
                                                </a>
                                            </li>
                                            <li role="presentation">
                                                <a href="#eft-citation-mla" aria-controls="eft-citation-mla" role="tab" data-toggle="tab">
                                                    <xsl:attribute name="title" select="'Modern Language Association style'"/>
                                                    <xsl:value-of select="'MLA'"/>
                                                </a>
                                            </li>
                                            <li role="presentation">
                                                <a href="#eft-citation-apa" aria-controls="eft-citation-apa" role="tab" data-toggle="tab">
                                                    <xsl:attribute name="title" select="'American Psychological Association style'"/>
                                                    <xsl:value-of select="'APA'"/>
                                                </a>
                                            </li>
                                        </ul>
                                        
                                        <div class="tab-content">
                                            
                                            <!-- CMS -->
                                            <div role="tabpanel" class="tab-pane active eft-citation" id="eft-citation-cms">
                                                <span class="content">
                                                    <xsl:value-of select="concat('84000.', ' ')"/>
                                                    <a class="italic underline">
                                                        <xsl:attribute name="href" select="$translation/@canonical-html"/>
                                                        <xsl:value-of select="string-join($translation/m:titles/m:title[@xml:lang eq 'en']/text())"/>
                                                    </a>
                                                    <xsl:value-of select="' ('"/>
                                                    <xsl:for-each select="(($translation/m:titles/m:title[@xml:lang eq 'Sa-Ltn'][text()][1]), ($translation/m:titles/m:title[@xml:lang eq 'Bo-Ltn'][text()])[1], $translation/m:toh/m:full)">
                                                        <xsl:if test="position() gt 1">
                                                            <xsl:value-of select="', '"/>
                                                        </xsl:if>
                                                        <span>
                                                            <xsl:call-template name="class-attribute">
                                                                <xsl:with-param name="lang" select="@xml:lang"/>
                                                            </xsl:call-template>
                                                            <xsl:value-of select="string-join(text())"/>
                                                        </span>
                                                    </xsl:for-each>
                                                    <xsl:value-of select="'). '"/>
                                                    <xsl:value-of select="concat('Translated by ', $translation/m:publication/m:team[1]/m:label[1], '. ')"/>
                                                    <xsl:value-of select="concat('Online publication.', ' ')"/>
                                                    <xsl:value-of select="concat('84000: Translating the Words of the Buddha, ', $translation/m:publication/m:edition/tei:date[1], '. ')"/>
                                                    <span class="break">
                                                        <xsl:value-of select="$translation/@canonical-html"/>
                                                    </span>
                                                    <xsl:value-of select="'.'"/>
                                                </span>
                                                <a href="#" data-clipboard="#eft-citation-cms .content">
                                                    <xsl:value-of select="'Copy'"/>
                                                </a>
                                            </div>
                                            
                                            <!-- MLA -->
                                            <div role="tabpanel" class="tab-pane eft-citation" id="eft-citation-mla">
                                                <span class="content">
                                                    <xsl:value-of select="concat('84000.', ' ')"/>
                                                    <a class="italic underline">
                                                        <xsl:attribute name="href" select="$translation/@canonical-html"/>
                                                        <xsl:value-of select="string-join($translation/m:titles/m:title[@xml:lang eq 'en']/text())"/>
                                                    </a>
                                                    <xsl:value-of select="' ('"/>
                                                    <xsl:for-each select="(($translation/m:titles/m:title[@xml:lang eq 'Sa-Ltn'][text()][1]), ($translation/m:titles/m:title[@xml:lang eq 'Bo-Ltn'][text()])[1], $translation/m:toh/m:full)">
                                                        <xsl:if test="position() gt 1">
                                                            <xsl:value-of select="', '"/>
                                                        </xsl:if>
                                                        <span>
                                                            <xsl:call-template name="class-attribute">
                                                                <xsl:with-param name="lang" select="@xml:lang"/>
                                                            </xsl:call-template>
                                                            <xsl:value-of select="string-join(text())"/>
                                                        </span>
                                                    </xsl:for-each>
                                                    <xsl:value-of select="'). '"/>
                                                    <xsl:value-of select="concat('Translated by ', $translation/m:publication/m:team[1]/m:label[1], ', ')"/>
                                                    <xsl:value-of select="concat('online publication,', ' ')"/>
                                                    <xsl:value-of select="concat('84000: Translating the Words of the Buddha, ', $translation/m:publication/m:edition/tei:date[1], ', ')"/>
                                                    <span class="break">
                                                        <xsl:value-of select="replace($translation/@canonical-html, '^https://', '')"/>
                                                    </span>
                                                    <xsl:value-of select="'.'"/>
                                                </span>
                                                <a href="#" data-clipboard="#eft-citation-mla .content">
                                                    <xsl:value-of select="'Copy'"/>
                                                </a>
                                            </div>
                                            
                                            <!-- APA -->
                                            <div role="tabpanel" class="tab-pane eft-citation" id="eft-citation-apa">
                                                <span class="content">
                                                    <xsl:value-of select="concat('84000.', $translation/m:publication/m:edition/tei:date[1] ! concat(' (',.,')'), ' ')"/>
                                                    <a class="italic underline">
                                                        <xsl:attribute name="href" select="$translation/@canonical-html"/>
                                                        <xsl:value-of select="string-join($translation/m:titles/m:title[@xml:lang eq 'en']/text())"/>
                                                    </a>
                                                    <xsl:value-of select="' ('"/>
                                                    <xsl:for-each select="(($translation/m:titles/m:title[@xml:lang eq 'Sa-Ltn'][text()][1]), ($translation/m:titles/m:title[@xml:lang eq 'Bo-Ltn'][text()])[1], $translation/m:toh/m:full)">
                                                        <xsl:if test="position() gt 1">
                                                            <xsl:value-of select="', '"/>
                                                        </xsl:if>
                                                        <span>
                                                            <xsl:call-template name="class-attribute">
                                                                <xsl:with-param name="lang" select="@xml:lang"/>
                                                            </xsl:call-template>
                                                            <xsl:value-of select="string-join(text())"/>
                                                        </span>
                                                    </xsl:for-each>
                                                    <xsl:value-of select="'). '"/>
                                                    <xsl:value-of select="concat('(', $translation/m:publication/m:team[1]/m:label[1], ', Trans.). ')"/>
                                                    <xsl:value-of select="'Online publication. '"/>
                                                    <xsl:value-of select="'84000: Translating the Words of the Buddha. '"/>
                                                    <span class="break">
                                                        <xsl:value-of select="$translation/@canonical-html"/>
                                                    </span>
                                                    <xsl:value-of select="'.'"/>
                                                </span>
                                                <a href="#" data-clipboard="#eft-citation-apa .content">
                                                    <xsl:value-of select="'Copy'"/>
                                                </a>
                                            </div>
                                            
                                        </div>
                                    
                                    </div>
                                    <hr/>
                                </div>
                            </xsl:if>
                            
                            <div id="contents-sidebar-related-links">
                                <h4>
                                    <xsl:value-of select="'Related links'"/>
                                </h4>
                                <ul>
                                    <!-- Add a link to other texts by this author -->
                                    <xsl:for-each select="$translation/m:source/m:attribution[@role = ('author', 'author-contested')][@xml:id]">
                                        
                                        <xsl:variable name="entity" select="key('entity-instance', @xml:id, $root)[1]/parent::m:entity" as="element(m:entity)?"/>
                                        <xsl:variable name="kb-page" select="key('related-pages', $entity/m:instance[@type eq 'knowledgebase-article'][1]/@id, $root)[1]" as="element(m:page)?"/>
                                        
                                        <xsl:if test="$kb-page">
                                            <li>
                                                <xsl:value-of select="'Other texts by '"/>
                                                <xsl:call-template name="attribution-label">
                                                    <xsl:with-param name="attribution" select="."/>
                                                    <xsl:with-param name="entity" select="$entity"/>
                                                    <xsl:with-param name="page" select="$kb-page"/>
                                                </xsl:call-template>
                                            </li>
                                        </xsl:if>
                                        
                                    </xsl:for-each>
                                    <li>
                                        <xsl:variable name="section" select="$translation/m:parent"/>
                                        <xsl:value-of select="'Other texts from '"/>
                                        <a>
                                            <xsl:attribute name="href" select="common:internal-href(concat('/section/', $section/@id, '.html'), (), (), /m:response/@lang)"/>
                                            <xsl:value-of select="$section/m:titles/m:title[@xml:lang eq 'en']"/>
                                        </a>
                                    </li>
                                    <li>
                                        <a>
                                            <xsl:attribute name="href" select="common:internal-href('/section/all-translated.html', (), (), /m:response/@lang)"/>
                                            <xsl:value-of select="'Published Translations'"/>
                                        </a>
                                    </li>
                                    <!--<li>
                                        <a>
                                            <xsl:attribute name="href" select="common:internal-href('/search.html', (), (), /m:response/@lang)"/>
                                            <xsl:value-of select="'Search the Collection'"/>
                                        </a>
                                    </li>-->
                                    <li>
                                        <a>
                                            <xsl:attribute name="href" select="common:internal-href('/', (), (), /m:response/@lang)"/>
                                            <xsl:value-of select="'Browse the Collection'"/>
                                        </a>
                                    </li>
                                    <li>
                                        <a target="84000-comms">
                                            <xsl:attribute name="href" select="common:homepage-link('', /m:response/@lang)"/>
                                            <xsl:value-of select="'84000 Homepage'"/>
                                        </a>
                                    </li>
                                </ul>
                            </div>
                            
                            <a class="btn btn-danger" target="84000-donate" id="content-sidebar-donate-button">
                                <xsl:attribute name="href">
                                    <xsl:call-template name="text">
                                        <xsl:with-param name="global-key" select="'about.common.sponsor-button-link'"/>
                                    </xsl:call-template>
                                </xsl:attribute>
                                <xsl:value-of select="'Sponsor Translation'"/>
                            </a>
                            
                        </div>
                    </div>
                    
                    <div class="fixed-btn-container close-btn-container right">
                        <button type="button" class="btn-round close close-collapse" aria-label="Close">
                            <span aria-hidden="true">
                                <i class="fa fa-times"/>
                            </span>
                        </button>
                    </div>
                    
                </div>
                
                <!-- Include the bookmarks sidebar -->
                <xsl:variable name="bookmarks-sidebar">
                    <m:bookmarks-sidebar>
                        <xsl:copy-of select="$eft-header/m:translation"/>
                    </m:bookmarks-sidebar>
                </xsl:variable>
                <xsl:apply-templates select="$bookmarks-sidebar"/>
                
            </xsl:if>
        
        </xsl:variable>
 
        <!-- Pass the content to the page -->
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="($translation/@canonical-html, '')[1]"/>
            <xsl:with-param name="page-class">
                <xsl:value-of select="'reading-room'"/>
                <xsl:value-of select="' translation'"/>
                <xsl:value-of select="concat(' ', $part-status)"/>
                <xsl:if test="$part-status eq 'part' and $requested-part gt ''">
                    <xsl:value-of select="concat(' part-', $requested-part)"/>
                </xsl:if>
            </xsl:with-param>
            <xsl:with-param name="page-title" select="string-join(($page-title/data(), '84000 Reading Room'), ' / ')"/>
            <xsl:with-param name="page-description" select="normalize-space(data($translation/m:part[@type eq 'summary']/tei:p[1]))"/>
            <xsl:with-param name="content" select="$content"/>
            <xsl:with-param name="additional-tags">
                
                <!-- Auto-discovery links for other formats -->
                <xsl:for-each select="$download-files">
                    <link rel="alternate">
                        <xsl:attribute name="href" select="@source"/>
                        <xsl:choose>
                            <xsl:when test="@type eq 'epub'">
                                <xsl:attribute name="type" select="'application/epub+zip'"/>
                            </xsl:when>
                            <xsl:when test="@type eq 'pdf'">
                                <xsl:attribute name="type" select="'application/pdf'"/>
                            </xsl:when>
                        </xsl:choose>
                    </link>
                </xsl:for-each>
                
                <!-- Add OPDS auto-discovery links for atom feeds -->
                <!--<link rel="related" type="application/atom+xml;profile=opds-catalog;kind=navigation" href="/section/lobby.navigation.atom" title="The 84000 Reading Room"/>-->
                <!--<link rel="related" type="application/atom+xml;profile=opds-catalog;kind=acquisition" href="/section/all-translated.acquisition.atom" title="84000: All Translated Texts"/>-->
                
                <xsl:variable name="part-map" as="xs:string*">
                    <xsl:if test="not($part-status eq 'complete')">
                        <xsl:for-each select="m:text-outline/m:pre-processed[@text-id eq $text-id][@type eq 'parts']//m:part">
                            <xsl:value-of select="concat('&#34;', @id, '&#34;:&#34;', (ancestor::m:part[not(@type eq 'translation')][last()]/@id, @id)[1], '&#34;')"/>
                        </xsl:for-each>
                        <xsl:for-each select="m:text-outline/m:pre-processed[@text-id eq $text-id][@type eq 'milestones']/m:milestone">
                            <xsl:value-of select="concat('&#34;', @id, '&#34;:&#34;', @part-id, '&#34;')"/>
                        </xsl:for-each>
                        <xsl:for-each select="m:text-outline/m:pre-processed[@text-id eq $text-id][@type eq 'end-notes']/m:end-note">
                            <xsl:value-of select="concat('&#34;', @id, '&#34;:&#34;', @part-id, '&#34;')"/>
                            <xsl:value-of select="concat('&#34;end-note-', @id, '&#34;:&#34;', $text-id, '-end-notes&#34;')"/>
                        </xsl:for-each>
                        <xsl:for-each select="m:text-outline/m:pre-processed[@text-id eq $text-id][@type eq 'glossary']/m:gloss">
                            <xsl:value-of select="concat('&#34;', @id, '&#34;:&#34;', $text-id, '-glossary&#34;')"/>
                        </xsl:for-each>
                        <xsl:for-each select="m:text-outline/m:pre-processed[@text-id eq $text-id][@type eq 'quotes']/m:quote">
                            <xsl:value-of select="concat('&#34;', @id, '&#34;:&#34;', @part-id, '&#34;')"/>
                        </xsl:for-each>
                        <xsl:for-each select="m:text-outline/m:pre-processed[@text-id eq $text-id][@type eq 'folio-refs']/m:folio-ref">
                            <xsl:value-of select="concat('&#34;', @id, '&#34;:&#34;', @part-id, '&#34;')"/>
                        </xsl:for-each>
                    </xsl:if>
                </xsl:variable>
                <script>
                    <xsl:value-of select="concat('var partMap = {', string-join($part-map, ','), '};')"/>
                </script>
                
            </xsl:with-param>
            <xsl:with-param name="text-id" select="$translation/@id"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template name="part">
        
        <xsl:param name="part" as="node()*"/>
        <xsl:param name="css-classes" as="xs:string" select="''"/>
        
        <!-- 'hide' allows the inclusion of content in the xml structure without outputting, also skip 'unpublished' -->
        <xsl:if test="$part[@content-status = ('complete', 'preview', 'passage')]">
            <div class="row">
                
                <!--<xsl:attribute name="data-content-status" select="$part/@content-status"/>-->
                
                <div class="col-md-offset-1 col-md-10 col-lg-offset-2 col-lg-8 print-width-override">
                    
                    <xsl:element name="{ if($part[@content-status = ('complete')]) then 'section' else 'aside' }" namespace="http://www.w3.org/1999/xhtml">
                        
                        <xsl:attribute name="id" select="$part/@id"/>
                        
                        <xsl:attribute name="data-part-type" select="$part/@type"/>
                        
                        <xsl:call-template name="class-attribute">
                            
                            <xsl:with-param name="base-classes" as="xs:string*">
                                
                                <xsl:value-of select="concat('part-type-', $part/@type)"/>
                                <xsl:value-of select="$css-classes"/>
                                <xsl:value-of select="'tei-parser'"/>
                                
                            </xsl:with-param>
                            
                            <xsl:with-param name="html-classes" as="xs:string*">
                                
                                <xsl:choose>
                                    <!-- Expand all -->
                                    <xsl:when test="$view-mode[@layout = ('expanded', 'flat')]">
                                        <xsl:value-of select="'show'"/>
                                    </xsl:when>
                                    <!-- Expand only the complete part -->
                                    <xsl:when test="$part[@content-status eq 'complete'] and $part[@id eq $requested-part]">
                                        <xsl:value-of select="'show'"/>
                                    </xsl:when>
                                    <!-- Collapse and flag as .partial -->
                                    <xsl:when test="$part[@content-status eq 'preview']">
                                        <xsl:value-of select="'preview partial'"/>
                                    </xsl:when>
                                    <!-- Collapse by default -->
                                    <xsl:otherwise>
                                        <xsl:value-of select="'preview'"/>
                                        <!--<xsl:if test="$view-mode[@client eq 'browser']">
                                            <xsl:value-of select="'delay-render'"/>
                                        </xsl:if>-->
                                    </xsl:otherwise>
                                </xsl:choose>
                                
                                <xsl:value-of select="'relative'"/>
                                
                            </xsl:with-param>
                            
                        </xsl:call-template>
                        
                        <xsl:call-template name="data-location-id-attribute">
                            <xsl:with-param name="node" select="$part"/>
                        </xsl:call-template>
                        
                        <xsl:if test="$view-mode[not(@layout eq 'part-only')]">
                            <hr class="hidden-print"/>
                        </xsl:if>
                        
                        <!-- The content -->
                        <xsl:choose>
                            
                            <xsl:when test="$part[@type eq 'end-notes']">
                                <xsl:call-template name="end-notes"/>
                            </xsl:when>
                            
                            <xsl:when test="$part[@type eq 'glossary']">
                                <xsl:call-template name="glossary"/>
                            </xsl:when>
                            
                            <xsl:when test="$part[@type eq 'citation-index']">
                                <xsl:call-template name="citation-index"/>
                            </xsl:when>
                            
                            <xsl:otherwise>
                                
                                <xsl:if test="not($part/tei:head[@type eq $part/@type][not(@key) or @key eq $toh-key][data()])">
                                    <xsl:apply-templates select="$part/parent::m:part[@type eq 'translation']/tei:head[@type eq 'translation'][not(@key) or @key eq $toh-key][data()]"/>
                                </xsl:if>
                                
                                <xsl:apply-templates select="$part/m:* | $part/tei:*"/>
                                
                            </xsl:otherwise>
                            
                        </xsl:choose>
                        
                        <!-- Add controls to expand / collapse -->
                        <xsl:if test="$part[@content-status = ('complete', 'preview')] and $view-mode[not(@layout = ('flat'))]">
                            
                            <xsl:call-template name="preview-controls">
                                
                                <xsl:with-param name="section-id" select="$part/@id"/>
                                <xsl:with-param name="log-click" select="true()"/>
                                <xsl:with-param name="log-click-text-id" select="$text-id"/>
                                
                                <!-- Provide complete navigation links so they will be followed by crawlers and right-click works -->
                                <xsl:with-param name="href">
                                    <xsl:choose>
                                        <xsl:when test="$part[@content-status = ('complete')]">
                                            <xsl:value-of select="concat('#', $part/@id)"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <!-- Validate that this is a root part -->
                                            <xsl:variable name="root-part" select="($part/ancestor-or-self::m:part[@id][@nesting eq '0'][not(@type = ('translation'))])[1]"/>
                                            <xsl:value-of select="m:translation-href($requested-resource, $root-part/@id, $requested-commentary, $part/@id)"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:with-param>
                                
                                <!-- The javascript will intercept and use this in the RR, loading the part into the skeleton of the text -->
                                <xsl:with-param name="href-override">
                                    <xsl:if test="$part[@content-status eq 'preview'] and $view-mode[@client = ('browser', 'ajax')]">
                                        <xsl:value-of select="concat('#', $part/@id)"/>
                                    </xsl:if>
                                </xsl:with-param>
                                
                            </xsl:call-template>
                            
                        </xsl:if>
                        
                    </xsl:element>
                
                </div>
            
            </div>
        </xsl:if>
        
    </xsl:template>
    
    <xsl:template name="titles">
        
        <xsl:variable name="main-titles" select="$translation/m:titles/m:title[normalize-space(text())]"/>
        <xsl:variable name="long-titles" select="$translation/m:long-titles/m:title[normalize-space(text())]"/>
        
        <div class="row">
            <section id="titles" class="col-md-offset-1 col-md-10 col-lg-offset-2 col-lg-8 print-width-override">
                
                <xsl:attribute name="data-part-type" select="'titles'"/>
                
                <!-- Include an additional page warning about incompleteness of rendering -->
                <xsl:if test="not($part-status eq 'complete')">
                    <div class="page page-first visible-print-block">
                        <div class="well text-center top-margin hidden-pdf">
                            
                            <p class="uppercase">
                                <xsl:call-template name="text">
                                    <xsl:with-param name="global-key" select="'translation.partial-text-warning'"/>
                                </xsl:call-template>
                            </p>
                            
                            <xsl:variable name="pdf-download" select="$download-files[@type eq 'pdf']"/>
                            <xsl:if test="$pdf-download">
                                <p>
                                    <xsl:call-template name="text">
                                        <xsl:with-param name="global-key" select="'translation.partial-text-link'"/>
                                    </xsl:call-template>
                                    <br/>
                                    <a target="_blank">
                                        <xsl:attribute name="title">
                                            <xsl:call-template name="download-label">
                                                <xsl:with-param name="type" select="$pdf-download/@type"/>
                                            </xsl:call-template>
                                        </xsl:attribute>
                                        <xsl:attribute name="href" select="$pdf-download/@source"/>
                                        <xsl:attribute name="download" select="$pdf-download/@target-file"/>
                                        <xsl:attribute name="class" select="'log-click'"/>
                                        <xsl:value-of select="$pdf-download/@source"/>
                                    </a>
                                </p>
                            </xsl:if>
                            
                        </div>
                    </div>
                </xsl:if>
                
                <!-- Main titles -->
                <div>
                    
                    <xsl:call-template name="class-attribute">
                        <xsl:with-param name="base-classes" as="xs:string*">
                            <xsl:value-of select="'page'"/>
                            <xsl:if test="$part-status eq 'complete'">
                                <xsl:value-of select="'page-first'"/>
                            </xsl:if>
                        </xsl:with-param>
                    </xsl:call-template>
                    
                    <div id="main-titles" class="ornamental-panel">
                        
                        <!-- Tibetan title -->
                        <xsl:if test="$main-titles[@xml:lang eq 'bo']">
                            <div class="panel-row">
                                <xsl:apply-templates select="$main-titles[@xml:lang eq 'bo']"/>
                            </div>
                        </xsl:if>
                        
                        <!-- English title -->
                        <h1 class="panel-row title main-title">
                            <xsl:for-each select="$page-title">
                                <xsl:choose>
                                    <xsl:when test="self::m:title">
                                        <span>
                                            <xsl:value-of select="."/>
                                        </span>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <br/>
                                        <span class="dot-parenth">
                                            <xsl:value-of select="' '"/>
                                            <xsl:value-of select="."/>
                                            <xsl:value-of select="' '"/>
                                        </span>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                        </h1>
                        
                        <!-- Sanskrit title -->
                        <xsl:if test="$main-titles[@xml:lang eq 'Sa-Ltn']">
                            <div class="panel-row">
                                <xsl:apply-templates select="$main-titles[@xml:lang eq 'Sa-Ltn']"/>
                            </div>
                        </xsl:if>
                        
                        <!-- Tibetan author -->
                        <xsl:variable name="sourceAuthors" select="$translation/m:source/m:attribution[@role = ('author','author-contested')][@xml:id]"/>
                        <xsl:if test="$sourceAuthors">
                            <div class="panel-row">
                                <div>
                                    <xsl:choose>
                                        <xsl:when test="$sourceAuthors[@role eq 'author-contested']">
                                            <xsl:value-of select="common:small-caps('Attributed to')"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="common:small-caps('by')"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </div>
                                <div class="align-center">
                                    <xsl:for-each select="$sourceAuthors">
                                        <xsl:if test="position() gt 1">
                                            <small>
                                                <xsl:choose>
                                                    <xsl:when test="$sourceAuthors[@role eq 'author-contested']">
                                                        <xsl:value-of select="' or '"/>
                                                    </xsl:when>
                                                    <xsl:when test="position() lt count($sourceAuthors)">
                                                        <xsl:value-of select="', '"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:value-of select="', and '"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </small>
                                        </xsl:if>
                                        <span>
                                            <xsl:call-template name="class-attribute">
                                                <xsl:with-param name="lang" select="@xml:lang"/>
                                            </xsl:call-template>
                                            <xsl:value-of select="normalize-space(text())"/> 
                                        </span>
                                    </xsl:for-each>
                                </div>
                            </div>
                        </xsl:if>
                        
                    </div>
                    
                </div>
                
                <!-- Long titles on a seperate page -->
                <xsl:if test="$long-titles or $translation[m:source]">
                    <div class="page">
                        
                        <!-- Long titles -->
                        <xsl:choose>
                            <xsl:when test="$long-titles">
                                <div id="long-titles">
                                    <xsl:apply-templates select="$long-titles[@xml:lang eq 'bo']"/>
                                    <xsl:apply-templates select="$long-titles[@xml:lang eq 'Bo-Ltn']"/>
                                    <xsl:apply-templates select="$long-titles[@xml:lang eq 'en']"/>
                                    <xsl:apply-templates select="$long-titles[@xml:lang eq 'Sa-Ltn']"/>
                                </div>
                            </xsl:when>
                            <xsl:when test="$main-titles[@xml:lang eq 'Bo-Ltn']">
                                <div id="long-titles">
                                    <xsl:apply-templates select="$main-titles[@xml:lang eq 'Bo-Ltn']"/>
                                </div>
                            </xsl:when>
                        </xsl:choose>
                        
                        <!-- Source references -->
                        <xsl:if test="$translation[m:source]">
                            <div id="toh">
                                
                                <div>
                                    <h3 class="dot-parenth">
                                        <xsl:apply-templates select="$translation/m:source/m:toh"/>
                                    </h3>
                                    <xsl:if test="$translation/m:source[m:scope//text()]">
                                        <p id="location">
                                            <xsl:apply-templates select="$translation/m:source/m:scope/node()"/>
                                        </p>
                                    </xsl:if>
                                </div>
                                
                                <xsl:if test="$translation/m:source/m:isCommentaryOf">
                                    <div class="top-margin">
                                        <div>
                                            <xsl:value-of select="common:small-caps('A commentary on')"/>
                                        </div>
                                        <div>
                                            <ul class="list-inline inline-dots dot-parenth">
                                                <xsl:for-each select="$translation/m:source/m:isCommentaryOf">
                                                    <xsl:variable name="commentary-title" select="(tei:bibl/tei:ref)[1]"/>
                                                    <li>
                                                        <a class="printable">
                                                            <xsl:attribute name="href" select="m:translation-href(@toh-key, (), $toh-key, ())"/>
                                                            <xsl:attribute name="data-dualview-href" select="m:translation-href(@toh-key, (), $toh-key, 'titles')"/>
                                                            <xsl:attribute name="data-dualview-title" select="$commentary-title || ' (root text)'"/>
                                                            <xsl:attribute name="target" select="concat('translation-', @toh-key)"/>
                                                            <xsl:value-of select="$commentary-title"/>
                                                        </a>
                                                    </li>
                                                </xsl:for-each>
                                            </ul>
                                        </div>
                                    </div>
                                </xsl:if>
                                
                                <xsl:variable name="supplementaryRoles" select="('translator', 'reviser')"/>
                                <xsl:for-each select="$supplementaryRoles">
                                    <xsl:variable name="supplementaryRole" select="."/>
                                    <xsl:variable name="roleAttributions" select="$translation/m:source/m:attribution[@role eq $supplementaryRole][@xml:id]"/>
                                    <xsl:if test="$roleAttributions">
                                        <div class="top-margin">
                                            <div>
                                                <xsl:choose>
                                                    <xsl:when test="$supplementaryRole eq 'reviser'">
                                                        <xsl:value-of select="common:small-caps('revision')"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:value-of select="common:small-caps('Translated into Tibetan by')"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </div>
                                            <div>
                                                <ul class="list-inline inline-dots dot-parenth">
                                                    <xsl:for-each select="$roleAttributions">
                                                        <li>
                                                            <span>
                                                                <xsl:call-template name="class-attribute">
                                                                    <xsl:with-param name="lang" select="@xml:lang"/>
                                                                </xsl:call-template>
                                                                <xsl:value-of select="normalize-space(text())"/> 
                                                            </span>
                                                        </li>
                                                    </xsl:for-each>
                                                </ul>
                                            </div>
                                        </div>
                                    </xsl:if>
                                </xsl:for-each>
                                
                            </div>
                        </xsl:if>
                        
                    </div>
                </xsl:if>
                
            </section>
        </div>
        
    </xsl:template>
    
    <xsl:template name="imprint">
        
        <div class="row">
            
            <section id="imprint" class="col-md-offset-1 col-md-10 col-lg-offset-2 col-lg-8 print-width-override">
                
                <xsl:attribute name="data-part-type" select="'imprint'"/>
                
                <h2 class="sr-only">
                    <xsl:value-of select="'Imprint'"/>
                </h2>
                
                <div class="page page-force">
                    
                    <xsl:if test="$translation[m:publication]">
                        
                        <div>
                            <img class="logo">
                                <!-- Update to set image in CSS -->
                                <xsl:attribute name="src" select="'/frontend/imgs/84000-logo.png'"/>
                                <xsl:attribute name="alt" select="'84000 logo'"/>
                            </img>
                        </div>
                        
                        <xsl:if test="$translation[@status = $render-status] and $translation/m:publication/m:contributors/m:summary[node()]">
                            <div class="well">
                                <xsl:for-each select="$translation/m:publication/m:contributors/m:summary">
                                    <p id="authours-summary">
                                        <xsl:apply-templates select="node()"/>
                                    </p>
                                </xsl:for-each>
                            </div>
                        </xsl:if>
                        
                        <div id="version">
                            
                            <p>
                                <xsl:choose>
                                    <xsl:when test="$translation/m:publication/m:publication-date castable as xs:date">
                                        <xsl:value-of select="concat('First published ', format-date($translation/m:publication/m:publication-date, '[Y]'))"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="'Not yet published'"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </p>
                            
                            <p id="edition">
                                <xsl:choose>
                                    <xsl:when test="$translation/m:publication/m:edition/tei:date[1] gt ''">
                                        <xsl:value-of select="concat('Current version ', $translation/m:publication/m:edition/text()[1], '(', $translation/m:publication/m:edition/tei:date[1], ')')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="'[No version]'"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </p>
                            
                            <p>
                                <xsl:value-of select="concat('Generated by 84000 Reading Room v', /m:response/@app-version)"/>
                            </p>
                            
                            <!-- Warning for part publications (Toh 8) -->
                            <xsl:if test="$translation/m:part[@type eq 'translation']/m:part[@content-status eq 'unpublished']">
                                <p>
                                    <span class="label label-info">
                                        <xsl:value-of select="'This is a partial publication, only including completed chapters'"/>
                                    </span>
                                </p>
                            </xsl:if>
                            
                        </div>
                        
                        <div id="publication-statement">
                            <p>
                                <xsl:apply-templates select="$translation/m:publication/m:publication-statement"/>
                            </p>
                        </div>
                        
                        <xsl:if test="$translation/m:publication/m:tantric-restriction[tei:p]">
                            
                            <div id="tantric-warning" class="well well-danger">
                                <xsl:for-each select="$translation/m:publication/m:tantric-restriction/tei:p">
                                    <p>
                                        <xsl:apply-templates select="node()"/>
                                    </p>
                                </xsl:for-each>
                            </div>
                            
                            <xsl:call-template name="tantra-warning">
                                <xsl:with-param name="id" select="'tantric-restriction-modal'"/>
                                <xsl:with-param name="modal-only" select="true()"/>
                                <xsl:with-param name="restricted-text-id" select="$toh-key"/>
                            </xsl:call-template>
                            
                        </xsl:if>
                        
                        <xsl:if test="$translation[@status = $render-status]">
                            <div id="license">
                                <img>
                                    <!-- Update to set image in CSS -->
                                    <xsl:attribute name="src" select="replace($translation/m:publication/m:license/@img-url, '^http:', 'https:')"/>
                                    <xsl:attribute name="alt" select="'Logo for the license'"/>
                                </img>
                                <xsl:for-each select="$translation/m:publication/m:license/tei:p">
                                    <p class="text-muted small">
                                        <xsl:apply-templates select="node()"/>
                                    </p>
                                </xsl:for-each>
                            </div>
                        </xsl:if>
                        
                    </xsl:if>
                    
                    <!-- Additional front-matter -->
                    <xsl:if test="$download-files">
                        
                        <!-- Download options -->
                        <nav class="download-options hidden-print text-center bottom-margin" aria-label="download-options-header">
                            
                            <header id="download-options-header">
                                <xsl:value-of select="'Options for downloading this publication'"/>
                            </header>
                            
                            <xsl:for-each select="$download-files">
                                <a target="_blank">
                                    <xsl:attribute name="title">
                                        <xsl:call-template name="download-label">
                                            <xsl:with-param name="type" select="@type"/>
                                        </xsl:call-template>
                                    </xsl:attribute>
                                    <xsl:attribute name="href" select="@source"/>
                                    <xsl:attribute name="download" select="@target-file"/>
                                    <xsl:attribute name="class" select="'btn-round log-click'"/>
                                    <xsl:attribute name="data-onclick-show" select="'#popup-footer-download-dana'"/>
                                    <xsl:call-template name="download-icon">
                                        <xsl:with-param name="type" select="@type"/>
                                    </xsl:call-template>
                                </a>
                            </xsl:for-each>
                            
                            <xsl:if test="$translation[@status eq '1']">
                                <a target="_blank">
                                    <xsl:attribute name="title">
                                        <xsl:call-template name="download-label">
                                            <xsl:with-param name="type" select="'app'"/>
                                        </xsl:call-template>
                                    </xsl:attribute>
                                    <xsl:attribute name="href" select="concat('https://app.84000.co/translation/', $toh-key, '.html')"/>
                                    <xsl:attribute name="class" select="'btn-round log-click'"/>
                                    <xsl:call-template name="download-icon">
                                        <xsl:with-param name="type" select="'app'"/>
                                    </xsl:call-template>
                                </a>
                            </xsl:if>
                            
                        </nav>
                        
                        <!-- Print statement -->
                        <aside id="print-version" class="visible-print-block text-center page page-force">
                            <xsl:call-template name="local-text">
                                <xsl:with-param name="local-key" select="'print-version'"/>
                            </xsl:call-template>
                        </aside>
                        
                    </xsl:if>
                    
                </div>
                
            </section>
            
        </div>
        
    </xsl:template>
    
    <xsl:template name="body-title">
        
        <xsl:if test="$translation/m:part[@type eq 'translation'] and $view-mode[not(@layout eq 'part-only')]">
            <div class="row">
                <div class="col-md-offset-1 col-md-10 col-lg-offset-2 col-lg-8 print-width-override">
                    
                    <section id="body-title">
                        
                        <xsl:call-template name="class-attribute">
                            <xsl:with-param name="base-classes">
                                <xsl:value-of select="'body-title'"/>
                            </xsl:with-param>
                            <xsl:with-param name="html-classes" as="xs:string*">
                                <xsl:value-of select="'part-type-translation'"/>
                                <xsl:if test="$view-mode[not(@parts = ('part', 'passage'))] or $requested-part = ('all', 'body', 'body-title')">
                                    <xsl:value-of select="'page'"/>
                                </xsl:if>
                            </xsl:with-param>
                        </xsl:call-template>
                        
                        <hr class="hidden-print"/>
                        
                        <h2 class="sr-only">
                            <xsl:value-of select="'Text Body'"/>
                        </h2>
                        
                        <div class="rw rw-section-head">
                            
                            <xsl:variable name="prelude" select="$translation/m:part[@type eq 'translation']/m:part[@type eq 'prelude']"/>
                            
                            <xsl:if test="not($prelude)">
                                <xsl:attribute name="id" select="$translation/m:part[@type eq 'translation']/@id"/>
                            </xsl:if>
                            
                            <div class="rw-heading heading-section chapter">
                                
                                <xsl:variable name="translation-head" select="$translation/m:part[@type eq 'translation']/tei:head[@type eq 'translation'][not(@key) or @key eq $toh-key][normalize-space(text())]" as="element(tei:head)?"/>
                                <xsl:variable name="honoration" select="$translation/m:part[@type eq 'translation']/tei:head[@type eq 'titleHon'][not(@key) or @key eq $toh-key][normalize-space(text())]" as="element(tei:head)?"/>
                                <xsl:variable name="main-title" select="$translation/m:part[@type eq 'translation']/tei:head[@type eq 'titleMain'][not(@key) or @key eq $toh-key][normalize-space(text())]" as="element(tei:head)?"/>
                                <xsl:variable name="sub-title" select="$translation/m:part[@type eq 'translation']/tei:head[@type eq 'sub'][not(@key) or @key eq $toh-key][normalize-space(text())]" as="element(tei:head)?"/>
                                <xsl:variable name="first-part-head" select="$translation/m:part[@type eq 'translation']/m:part[1]/tei:head[@type eq parent::m:part/@type][normalize-space(text())][1]" as="element(tei:head)?"/>
                                
                                <!-- If the first parent head is the same as the main title we want to use the translation part head in the first chapter, so not here -->
                                <xsl:if test="$translation-head and data($first-part-head) and not(data($first-part-head) eq data($main-title)) and not($prelude)">
                                    <div class="h3">
                                        <xsl:value-of select="$translation-head[1]/node()"/>
                                    </div>
                                </xsl:if>
                                
                                <xsl:if test="$main-title">
                                    <div class="h1 break">
                                        <xsl:if test="$sub-title[following-sibling::tei:head[1][@type eq 'titleHon']]">
                                            <small>
                                                <xsl:apply-templates select="$sub-title[1]/node()"/>
                                            </small>
                                            <br/>
                                        </xsl:if>
                                        <xsl:if test="$honoration">
                                            <small>
                                                <xsl:apply-templates select="$honoration[1]/node()"/>
                                            </small>
                                            <br/>
                                        </xsl:if>
                                        <xsl:if test="$sub-title[following-sibling::tei:head[1][@type eq 'titleMain']]">
                                            <small>
                                                <xsl:apply-templates select="$sub-title[1]/node()"/>
                                            </small>
                                            <br/>
                                        </xsl:if>
                                        <xsl:apply-templates select="$main-title[1]/node()"/>
                                        <xsl:if test="$sub-title[not(following-sibling::tei:head[1][@type = ('titleHon', 'titleMain')])]">
                                            <br/>
                                            <small>
                                                <xsl:apply-templates select="$sub-title[1]/node()"/>
                                            </small>
                                        </xsl:if>
                                    </div>
                                </xsl:if>
                                
                            </div>
                            
                        </div>
                        
                    </section>
                    
                </div>
            </div>
        </xsl:if>
        
    </xsl:template>
    
    <xsl:template name="prelude-title">
        
        <xsl:if test="$translation/m:part[@type eq 'translation'] and $view-mode[not(@layout eq 'part-only')]">
            <div class="row">
                <div class="col-md-offset-1 col-md-10 col-lg-offset-2 col-lg-8 print-width-override">
                    
                    <section id="prelude-title">
                        
                        <xsl:call-template name="class-attribute">
                            <xsl:with-param name="base-classes">
                                <xsl:value-of select="'body-title'"/>
                            </xsl:with-param>
                            <xsl:with-param name="html-classes" as="xs:string*">
                                <xsl:value-of select="'part-type-prelude'"/>
                                <xsl:if test="$view-mode[not(@parts = ('part', 'passage'))] or $requested-part = ('all', 'body')">
                                    <xsl:value-of select="'page'"/>
                                </xsl:if>
                            </xsl:with-param>
                        </xsl:call-template>
                        
                        <hr class="hidden-print"/>
                        
                        <h2 class="sr-only">
                            <xsl:value-of select="'Text Prelude'"/>
                        </h2>
                        
                        <div class="rw rw-section-head">
                            
                            <xsl:attribute name="id" select="$translation/m:part[@type eq 'translation']/@id"/>
                            
                            <div class="rw-heading heading-section chapter">
                                
                                <xsl:variable name="translation-head" select="$translation/m:part[@type eq 'translation']/tei:head[@type eq 'translation'][not(@key) or @key eq $toh-key][normalize-space(text())]" as="element(tei:head)?"/>
                                <xsl:variable name="section-title" select="$translation/m:part[@type eq 'translation']/tei:head[@type eq 'titleCatalogueSection'][not(@key) or @key eq $toh-key][normalize-space(text())]" as="element(tei:head)?"/>
                                
                                <xsl:if test="$translation-head">
                                    <div class="h3">
                                        <xsl:value-of select="$translation-head[1]/node()"/>
                                    </div>
                                </xsl:if>
                                
                                <div class="h1 break">
                                    <xsl:apply-templates select="$section-title[1]/node()"/>
                                </div>
                                
                            </div>
                            
                        </div>
                        
                    </section>
                    
                </div>
            </div>
        </xsl:if>
        
    </xsl:template>
    
</xsl:stylesheet>