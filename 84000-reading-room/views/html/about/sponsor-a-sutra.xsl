<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">

    <xsl:import href="about.xsl"/>

    <xsl:template match="/m:response">

        <xsl:variable name="content">

            <h3>General Information</h3>

            <div class="row">
                <div class="col-sm-8">

                    <p> 84000: Translating the Words of the Buddha aims to
                            <strong>translate</strong> all of the Buddha’s words into modern
                        languages, and <strong>make them available</strong> to everyone. </p>
                    <p>
                        <strong>Sponsor A Sutra</strong> is an opportunity to support the
                        translation of a major text. Some of the long, important sutras require a
                        sizeable amount of funding to ensure the translation continues through to
                        completion. Your support is needed for the successful translation of these
                        texts. </p>
                    <h4>How much does it cost to sponsor?</h4>
                    <p> Sponsorship opportunities are now available in sections of: </p>
                    <ul>
                        <li> 100 pages (US$25,000) </li>
                        <li> 150 pages (US$37,500) </li>
                        <li> 200 pages (US$50,000) or more. </li>
                    </ul>
                    <p> All donations are considered unrestricted contributions, enabling 84000 to
                        carry out their goals of translation and global access efficiently and
                        effectively. Please note that per sutra suggested donation amounts are
                        approximations only, and the actual cost may be greater or lesser when the
                        overall costs of translation, editorial work, publication, and project
                        management are taken into account. </p>
                    <h4>How will the funds be used?</h4>
                    <p> The funds will be used to cover the costs of translation, editorial work,
                        publication, and project management. Please see <a href="/about/work-flow/" target="_blank" rel="noopener">"What It Takes To Produce A Page of
                            Translation"</a> to learn more about the many stages required for high
                        quality translation. </p>
                    <h4>Who can sponsor?</h4>
                    <p> Anyone can make a sponsorship as an individual or family. Sponsorships can
                        also be made in the name of a group (such as a company, sangha or temple),
                        with the requirement that the group assigns a single contact person, and
                        that one person will be designated as the sole recipient of any
                        acknowledgement letters or gifts from 84000. </p>
                    <h4>How will donors be acknowledged?</h4>
                    <p> Donors will be recognized in the acknowledgements section of the text. </p>
                    <p> In appreciation of your generous support, all the names and the dedication
                        messages will be offered for prayers during the Dzongsar Monlam prayer
                        festivals held biennially in Bodhgaya, India. </p>
                </div>
                <div class="col-sm-4">
                    <div class="text-center bottom-margin">
                        <a class="btn btn-primary" href="https://84000.secure.force.com/donate" target="_blank" rel="noopener"> Donate online </a>
                    </div>
                    <div class="well well-sm small">
                        <p>You can sponsor the translation of a major sutra, in sections of: </p>
                        <ul>
                            <li>100 pages (US$25,000)</li>
                            <li>150 pages (US$37,500)</li>
                            <li>200 pages (US$50,000) or more.</li>
                        </ul>
                        <p>All sponsors will be acknowledged in the sponsored sutra within 30 words.</p>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-sm-12">
                    
                    <h3>Texts Available for Sponsorship</h3>

                    <div id="accordion" class="list-group accordion" role="tablist" aria-multiselectable="false">
                        
                        <xsl:variable name="priority-texts" select="m:texts/m:text[m:translation/@sponsored eq 'priority']"/>
                        <xsl:if test="count($priority-texts)">
                            <xsl:call-template name="expand-item">
                                <xsl:with-param name="id" select="'priority'"/>
                                <xsl:with-param name="title" select="'Priority Texts'"/>
                                <xsl:with-param name="texts" select="$priority-texts"/>
                                <xsl:with-param name="description">
                                    <p class="italic">The sponsorship, translation, and publication of texts in this section are considered a priority for 84000.</p>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:if>
                        
                        <xsl:call-template name="expand-item">
                            <xsl:with-param name="id" select="'group-1'"/>
                            <xsl:with-param name="title" select="'Sponsorship of up to 100 pages (US$25,000)'"/>
                            <xsl:with-param name="texts" select="m:texts/m:text[tei:bibl/tei:location/@count-pages/number() le 100]"/>
                        </xsl:call-template>
                        
                        <xsl:call-template name="expand-item">
                            <xsl:with-param name="id" select="'group-2'"/>
                            <xsl:with-param name="title" select="'Sponsorship of up to 150 pages (US$37,500)'"/>
                            <xsl:with-param name="texts" select="m:texts/m:text[tei:bibl/tei:location/@count-pages/number() gt 100][tei:bibl/tei:location/@count-pages/number() le 150]"/>
                        </xsl:call-template>
                        
                        <xsl:call-template name="expand-item">
                            <xsl:with-param name="id" select="'group-3'"/>
                            <xsl:with-param name="title" select="'Sponsorship of up to 200 pages (US$50,000)'"/>
                            <xsl:with-param name="texts" select="m:texts/m:text[tei:bibl/tei:location/@count-pages/number() gt 150][tei:bibl/tei:location/@count-pages/number() le 200]"/>
                        </xsl:call-template>
                        
                        <xsl:call-template name="expand-item">
                            <xsl:with-param name="id" select="'group-4'"/>
                            <xsl:with-param name="title" select="'Sponsorship of more than 200 pages'"/>
                            <xsl:with-param name="texts" select="m:texts/m:text[tei:bibl/tei:location/@count-pages/number() gt 200]"/>
                            <xsl:with-param name="description">
                                <div class="well well-sm">
                                    <h5>Explanantion:</h5>
                                    <ul class="list-unstyled small">
                                        <li>
                                            <img>
                                                <xsl:attribute name="src" select="concat($front-end-path, '/imgs/blue_person.png')"/>
                                            </img> represents no. of sponsorship opportunities available.
                                        </li>
                                        <li>
                                            <img>
                                                <xsl:attribute name="src" select="concat($front-end-path, '/imgs/orange_person.png')"/>
                                            </img> represents no. of sponsorship opportunities taken up.
                                        </li>
                                    </ul>
                                </div>
                            </xsl:with-param>
                        </xsl:call-template>
                        
                    </div>
                    <p>For more information, please contact Huang Jing Rui, executive director, at: <a href="mailto:jingrui@84000.co">jingrui@84000.co</a>
                    </p>
                </div>
                
            </div>


        </xsl:variable>

        <xsl:call-template name="about">
            <xsl:with-param name="sub-content" select="$content"/>
        </xsl:call-template>

    </xsl:template>
    
    <xsl:template name="expand-item">
        <xsl:param name="id" required="yes" as="xs:string"/>
        <xsl:param name="title" required="yes" as="xs:string"/>
        <xsl:param name="description" required="no" as="node()*"/>
        <xsl:param name="texts" required="yes" as="element()*"/>
        <div class="list-group-item">
            <div role="tab">
                <xsl:attribute name="id" select="concat($id, '-heading')"/>
                <a class="center-vertical full-width collapsed" role="button" data-toggle="collapse" data-parent="#accordion" aria-expanded="false">
                    <xsl:attribute name="href" select="concat('#', $id, '-detail')"/>
                    <xsl:attribute name="aria-controls" select="concat($id, '-detail')"/>
                    <span>
                        <h3 class="list-group-item-heading">
                            <xsl:value-of select="$title"/>
                        </h3>
                    </span>
                    <span class="text-right">
                        <i class="fa fa-plus collapsed-show"/>
                        <i class="fa fa-minus collapsed-hide"/>
                    </span>
                </a>
            </div>
            <div class="collapse" role="tabpanel" aria-expanded="false">
                <xsl:attribute name="id" select="concat($id, '-detail')"/>
                <xsl:attribute name="aria-labelledby" select="concat($id, '-heading')"/>
                <div class="detail">
                    <xsl:copy-of select="$description"/>
                    <xsl:choose>
                        <xsl:when test="count($texts)">
                             <div class="table-responsive">
                                <table class="table">
                                    <thead>
                                        <tr>
                                            <th>Toh</th>
                                            <th>Title</th>
                                            <th>Pages</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <xsl:for-each select="$texts">
                                            <tr>
                                                <th class="nowrap">
                                                    <xsl:value-of select="m:toh/m:base"/>
                                                </th>
                                                <td>
                                                    
                                                    <ul class="list-inline inline-dots no-bottom-margin">
                                                        <li class="text-sa">
                                                            <xsl:value-of select="m:titles/m:title[@xml:lang eq 'sa-ltn']"/>
                                                        </li>
                                                        <li class="text-bo">
                                                            <xsl:value-of select="m:titles/m:title[@xml:lang eq 'bo']"/>
                                                        </li>
                                                    </ul>
                                                    
                                                    <p>
                                                        <xsl:value-of select="m:titles/m:title[@xml:lang eq 'en']"/>
                                                    </p>
                                                    
                                                    <xsl:if test="m:translation/@sponsored eq 'reserved'">
                                                        <p class="text-danger">Already reserved for sponsorship</p>
                                                    </xsl:if>
                                                    
                                                    <xsl:if test="m:summary/tei:p">
                                                        <div class="small">
                                                            <a data-toggle="collapse" class="center-vertical collapsed">
                                                                <xsl:attribute name="href" select="'#'"/>
                                                                <xsl:attribute name="data-target" select="concat('#', m:toh/@key, '-summary')"/>
                                                                <span>
                                                                    <span class="collapsed-show">+</span>
                                                                    <span class="collapsed-hide">-</span>
                                                                </span>
                                                                <span>
                                                                    <xsl:value-of select="'Summary'"/>
                                                                </span>
                                                            </a>
                                                            <div class="collapse">
                                                                <xsl:attribute name="id" select="concat(m:toh/@key, '-summary')"/>
                                                                <xsl:for-each select="m:summary/tei:p">
                                                                    <p>
                                                                        <xsl:value-of select="fn:normalize-space(.)"/>
                                                                    </p>
                                                                </xsl:for-each>
                                                            </div>
                                                        </div>

                                                    </xsl:if>
                                                </td>
                                                <td>
                                                    <xsl:value-of select="tei:bibl/tei:location/@count-pages"/>
                                                </td>
                                            </tr>
                                        </xsl:for-each>
                                    </tbody>
                                </table>
                            </div>
                        </xsl:when>
                        <xsl:otherwise>
                            <hr class="sml-margin"/>
                            <p class="text-muted">There are currently no texts of this type proposed for sponsorship.</p>
                        </xsl:otherwise>
                    </xsl:choose>
                    
                </div>
            </div>
        </div>
    </xsl:template>

</xsl:stylesheet>