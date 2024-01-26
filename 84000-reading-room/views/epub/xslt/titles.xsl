<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:epub="http://www.idpf.org/2007/ops" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="3.0">
    
    <xsl:import href="../../../xslt/tei-to-xhtml.xsl"/>
    <xsl:import href="epub-page.xsl"/>
    
    <!-- epub:types https://idpf.github.io/epub-vocabs/structure/ -->
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="main-titles" select="m:translation/m:titles/m:title[normalize-space(text())]"/>
        <xsl:variable name="long-titles" select="m:translation/m:long-titles/m:title[normalize-space(text())]"/>
        <xsl:variable name="attributions" select="m:translation/m:source/m:attribution[@xml:id]"/>
        
        <xsl:call-template name="epub-page">
            <xsl:with-param name="page-title" select="'Title'"/>
            <xsl:with-param name="content">
                <div>
                    
                    <xsl:attribute name="id" select="'titles'"/>
                    
                    <section epub:type="halftitlepage" class="new-page heading-section">
                        
                        <xsl:if test="$main-titles[@xml:lang eq 'bo']">
                           <h2 class="main-title text-bo">
                               <xsl:apply-templates select="concat('༄༅། །', $main-titles[@xml:lang eq 'bo'])"/>
                           </h2>
                        </xsl:if>
                        
                        <h1 class="main-title">
                            <xsl:apply-templates select="$main-titles[@xml:lang eq 'en']"/>
                        </h1>
                        
                        <xsl:if test="$main-titles[@xml:lang eq 'Sa-Ltn']">
                            <h2 class="main-title text-sa">
                                <xsl:apply-templates select="$main-titles[@xml:lang eq 'Sa-Ltn']"/>
                            </h2>
                        </xsl:if>
                        
                        <xsl:if test="$attributions[@role = ('author','author-contested')]">
                            <div>
                                <h3>
                                    <xsl:choose>
                                        <xsl:when test="$attributions[@role eq 'author-contested']">
                                            <xsl:value-of select="common:small-caps('Attributed to')"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="common:small-caps('by')"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </h3>
                                <div>
                                    <xsl:for-each select="$attributions[@role = ('author','author-contested')]">
                                        <xsl:if test="position() gt 1">
                                            <small>
                                                <xsl:choose>
                                                    <xsl:when test="$attributions[@role eq 'author-contested']">
                                                        <xsl:value-of select="' or '"/>
                                                    </xsl:when>
                                                    <xsl:when test="position() lt count($attributions[@role = ('author','author-contested')])">
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
                        
                        <img src="image/logo-stacked.png" alt="84000 Translating the Words of the Buddha Logo" class="logo logo-84000"/>
                    
                    </section>
                    
                    <section epub:type="titlepage" class="new-page">
                        
                        <div class="heading-section">
                            
                            <xsl:if test="$long-titles[@xml:lang eq 'bo']">
                                <h2 class="text-bo">
                                    <xsl:apply-templates select="$long-titles[@xml:lang eq 'bo']"/>
                                </h2>
                            </xsl:if>
                            
                            <xsl:if test="$long-titles[@xml:lang eq 'Bo-Ltn']">
                                <h2>
                                    <xsl:apply-templates select="$long-titles[@xml:lang eq 'Bo-Ltn']"/>
                                </h2>
                            </xsl:if>
                            
                            <xsl:if test="$long-titles[@xml:lang eq 'en']">
                                <h1>
                                    <xsl:apply-templates select="$long-titles[@xml:lang eq 'en']"/>
                                </h1>
                            </xsl:if>
                            
                            <xsl:if test="$long-titles[@xml:lang eq 'Sa-Ltn']">
                                <h2 class="text-sa">
                                    <xsl:apply-templates select="$long-titles[@xml:lang eq 'Sa-Ltn']"/>
                                </h2>
                            </xsl:if>
                            
                        </div>
                        
                        <div class="source">
                            
                            <h3 class="dot-parenth">
                                <xsl:apply-templates select="m:translation/m:source/m:toh"/>
                            </h3>
                            
                            <xsl:if test="m:translation/m:source[m:scope//text()]">
                                <p id="location">
                                    <xsl:apply-templates select="m:translation/m:source/m:scope/node()"/>
                                </p>
                            </xsl:if>
                            
                        </div>
                        
                        <xsl:variable name="supplementaryRoles" select="('translator', 'reviser')"/>
                        <xsl:if test="$attributions[@role = $supplementaryRoles]">
                            <xsl:for-each select="$supplementaryRoles">
                                <xsl:variable name="supplementaryRole" select="."/>
                                <xsl:variable name="roleAttributions" select="$attributions[@role eq $supplementaryRole]"/>
                                <xsl:if test="$roleAttributions">
                                    <div>
                                        <h3>
                                            <xsl:choose>
                                                <xsl:when test="$supplementaryRole eq 'reviser'">
                                                    <xsl:value-of select="common:small-caps('revision')"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="common:small-caps('Translated into Tibetan by')"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </h3>
                                        <div>
                                            <ul class="list-inline inline-dots">
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
                        </xsl:if>
                        
                    </section>
                    
                </div>
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
</xsl:stylesheet>