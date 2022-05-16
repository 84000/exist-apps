<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:m="http://read.84000.co/ns/1.0" version="2.0">
    
    <xsl:include href="engine/2012.engine.xsl"/>
    
    <xsl:output omit-xml-declaration="no" indent="no"/>
    
    <xsl:variable name="alphabet" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
    
    <xsl:template match="/">
        
        <xsl:variable name="rows" select="//m:spreadsheet-data/*"/>
        <xsl:variable name="row1cols" select="//m:spreadsheet-data/*[1]/*"/>
        
        <xsl:call-template name="generate_excel">
            <xsl:with-param name="author">84000 Translating the Words of the Buddha</xsl:with-param>
            <xsl:with-param name="sheetContents">
                <worksheet>
                    <sheetPr filterMode="false">
                        <pageSetUpPr fitToPage="false"/>
                    </sheetPr>
                    <dimension ref="A1:{ substring($alphabet, count($row1cols), 1) }{count($rows)}"/>
                    <sheetViews>
                        <sheetView showFormulas="false" showGridLines="true" showRowColHeaders="true" showZeros="true" rightToLeft="false" tabSelected="true" showOutlineSymbols="true" defaultGridColor="true" view="normal" topLeftCell="A1" colorId="64" zoomScale="100" zoomScaleNormal="100" zoomScalePageLayoutView="100" workbookViewId="0">
                            <pane xSplit="0" ySplit="1" topLeftCell="A2" activePane="bottomLeft" state="frozen"/>
                            <selection pane="topLeft" activeCell="A1" activeCellId="0" sqref="A1"/>
                            <selection pane="bottomLeft" activeCell="A1" activeCellId="0" sqref="A1"/>
                        </sheetView>
                    </sheetViews>
                    <sheetFormatPr defaultColWidth="10" defaultRowHeight="12.8" zeroHeight="false" outlineLevelRow="0" outlineLevelCol="0"/>
                    <cols>
                        <xsl:for-each select="$row1cols">
                            <xsl:variable name="colNum" select="position()"/>
                            <xsl:variable name="width">
                                <xsl:choose>
                                    <xsl:when test="@width">
                                        <xsl:value-of select="@width"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="'20'"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <col min="{ $colNum }" max="{ $colNum }" collapsed="false" customWidth="true" hidden="false" outlineLevel="0" style="0" width="{ $width }"/>
                        </xsl:for-each>
                    </cols>
                    <sheetData>
                        <row r="1" hidden="false" customHeight="false" outlineLevel="0" collapsed="false">
                            <xsl:for-each select="$row1cols">
                                <xsl:variable name="colNum" select="position()"/>
                                <c r="{substring($alphabet, $colNum, 1)}1" t="inlineStr">
                                    <is>
                                        <t>
                                            <xsl:value-of select="local-name(.) ! replace(., '_', ' ')"/>
                                        </t>
                                    </is>
                                </c>
                            </xsl:for-each>
                        </row>
                        <xsl:apply-templates select="$rows" mode="row"/>
                    </sheetData>
                </worksheet>
            </xsl:with-param>
            <xsl:with-param name="styles">
                <styleSheet/>
            </xsl:with-param>
            <xsl:with-param name="themes">
                <theme xmlns="http://schemas.openxmlformats.org/drawingml/2006/main" name="Blank Theme"/>
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template match="*" mode="row">
        <xsl:variable name="rowNum" select="position() + 1"/>
        <row r="{ $rowNum }" hidden="false" customHeight="false" outlineLevel="0" collapsed="false">
            <xsl:for-each select="*">
                <xsl:variable name="colNum" select="position()"/>
                <c r="{substring($alphabet, $colNum, 1)}{$rowNum}" t="inlineStr">
                    <is>
                        <t>
                            <xsl:value-of select="."/>
                        </t>
                    </is>
                </c>
            </xsl:for-each>
        </row>
    </xsl:template>
    
</xsl:stylesheet>