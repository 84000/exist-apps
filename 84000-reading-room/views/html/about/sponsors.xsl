<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:import href="about.xsl"/>
    
    <xsl:template match="/m:response">
        <xsl:variable name="content">
            
            <ul class="nav nav-tabs" role="tablist" id="sponsors-tabs">
                <xsl:for-each select="m:tabs/m:tab">
                    <li role="presentation">
                        <xsl:if test="@active eq '1'">
                            <xsl:attribute name="class" select="'active'"/>
                        </xsl:if>
                        <a role="tab" data-toggle="tab">
                            <xsl:attribute name="href" select="concat('#', @id,'-tab')"/>
                            <xsl:attribute name="aria-controls" select="@id"/>
                            <xsl:value-of select="text()"/>
                        </a>
                    </li>
                </xsl:for-each>
            </ul>
            
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane" id="founding-tab">
                    <xsl:attribute name="class" select="if(m:tabs/m:tab[@id eq 'founding']/@active eq '1') then 'tab-pane fade in active' else 'tab-pane fade'"/>
                    <p>We would like to thank the 108 Founding Sponsors who so generously provided the seed funding to help 84000 get started with its task of translating the words of the Buddha. Each of these sponsors gave or pledged to give between $50,000-$250,000 to help us begin our journey. In addition to providing the funding for the initial rounds of translations, the funds are being used or have been used to: create the infrastructure for reviewing, editing, and pre-publication work; develop the tools and resources necessary for translation work; train translators and editors; and offset both the costs of the initial planning, and the current and ongoing administrative and operating costs.</p>
                    <p>With the vision and generosity of these Founding Sponsors, 84000 has been able to successfully launch and significantly progress with the immense task of translating the words of the Buddha. We offer our heartfelt thanks to all our Founding Sponsors for enabling us to safeguard this invaluable world heritage, and making it available for generations to come.</p>
                    <p>Dzongsar Khyentse Rinpoche, chairperson of 84000, has written a message addressed to all 108 Founding Sponsors. Click here to <a href="http://84000.co/message-to-founding-sponsors/">view Rinpoche’s message</a>.</p>
                    <h3>Our Founding Sponsors</h3>
                    <ol>
                        <xsl:for-each select="m:sponsors/m:sponsor[m:type[@id eq 'founding']]">
                            <li>
                                <xsl:value-of select="m:label"/>
                            </li>
                        </xsl:for-each>
                    </ol>
                </div>
                <div role="tabpanel" class="tab-pane" id="matching-funds-tab">
                    <xsl:attribute name="class" select="if(m:tabs/m:tab[@id eq 'matching-funds']/@active eq '1') then 'tab-pane fade in active' else 'tab-pane fade'"/>
                    <p>The Matching Funds Program is designed to incentivize small-dollar donors to give to 84000 on a recurring basis by offering to match those donations dollar-for-dollar. We would like to thank the following Matching Funds sponsors for their gift to 84000 and their generosity in allowing small-dollar donors to feel their contribution is making a more significant impact on the progress of the translation of the Tibetan Buddhist canon.</p>
                    <h3>Our Matching Funds Sponsors</h3>
                    <ul class="list-unstyled">
                        <xsl:for-each select="m:sponsors/m:sponsor[m:type[@id eq 'matching-funds']]">
                            <li>
                                <xsl:value-of select="m:label"/>
                            </li>
                        </xsl:for-each>
                    </ul>
                </div>
                <div role="tabpanel" class="tab-pane" id="sutra-tab">
                    <xsl:attribute name="class" select="if(m:tabs/m:tab[@id eq 'sutra']/@active eq '1') then 'tab-pane fade in active' else 'tab-pane fade'"/>
                    <p>Every year, we commission a new batch of translations. Some of the designated texts are long, important sūtras that require a sizeable amount of funding in order to see the translation process through to completion. We would like to thank our sponsors for their generous support of the <a href="http://84000.co/sutra">“Sponsor A Sūtra”</a> program.</p>
                    <h3>Our Sūtra Sponsors</h3>
                    <div class="text-list">
                        <div class="row table-headers">
                            <div class="col-sm-2 hidden-xs">Toh</div>
                            <div class="col-sm-10">Title</div>
                        </div>
                        <div class="list-section">
                            <xsl:for-each select="m:sponsored-texts/m:text">
                                <xsl:sort select="number(m:toh/@number)"/>
                                <xsl:sort select="m:toh/@letter"/>
                                <xsl:sort select="number(m:toh/@chapter-number)"/>
                                <xsl:sort select="m:toh/@chapter-letter"/>
                                <div class="row list-item">
                                    
                                    <div class="col-sm-2">
                                        <xsl:value-of select="m:toh/m:full"/>
                                        <xsl:call-template name="status-label">
                                            <xsl:with-param name="status-group" select="@status-group"/>
                                        </xsl:call-template>
                                    </div>
                                    
                                    <div class="col-sm-10">
                                        
                                        <xsl:call-template name="text-list-title">
                                            <xsl:with-param name="text" select="."/>
                                        </xsl:call-template>
                                        
                                        <xsl:call-template name="text-list-subtitles">
                                            <xsl:with-param name="text" select="."/>
                                        </xsl:call-template>
                                        
                                        <xsl:if test="m:sponsors/tei:div[@type eq 'acknowledgment']/tei:p">
                                            <hr/>
                                            <div>
                                                <xsl:for-each select="m:sponsors/tei:div[@type eq 'acknowledgment']/tei:p">
                                                    <p>
                                                        <xsl:value-of select="data(.)"/>
                                                    </p>
                                                </xsl:for-each>
                                                <xsl:if test="m:sponsorship-status/m:status[@id eq 'part']">
                                                    <p class="text-muted">
                                                        <a href="http://84000.co/sutra" class="italic">
                                                            <xsl:value-of select="'There are further sponsorship opportunities for this translation.'"/>
                                                        </a>
                                                    </p>
                                                </xsl:if>
                                            </div>
                                            
                                        </xsl:if>
                                        
                                        <xsl:call-template name="expandable-summary">
                                            <xsl:with-param name="text" select="."/>
                                        </xsl:call-template>
                                        
                                    </div>
                                </div>
                                
                            </xsl:for-each>
                        </div>
                    </div>
                    
                </div>
                
            </div>
            
        </xsl:variable>
        
        <xsl:call-template name="about">
            <xsl:with-param name="sub-content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>