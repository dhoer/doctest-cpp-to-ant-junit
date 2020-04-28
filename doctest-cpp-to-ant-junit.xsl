<?xml version="1.0" encoding="UTF-8"?>
<!--
MIT License

Copyright (c) 2020 Dennis Hoer

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" version="1.0" indent="yes" encoding="utf-8"/>

    <xsl:variable name="binary"
                  select="tokenize(/doctest/@binary, '/')[last()]"/>

    <xsl:template match="/">
        <testsuites>
            <xsl:apply-templates/>
        </testsuites>
    </xsl:template>

    <xsl:template match="TestSuite">
        <xsl:variable name="index"
                      select="count(preceding-sibling::*[name() = name(current())])"/>
        <testsuite>
            <xsl:attribute name="package">
                <xsl:value-of select="$binary"/>
            </xsl:attribute>
            <xsl:attribute name="id">
                <xsl:value-of select="$index"/>
            </xsl:attribute>
            <xsl:attribute name="name">
                <xsl:choose>
                    <xsl:when test="@name">
                        <xsl:value-of select="@name"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$index"/>_<xsl:value-of select="tokenize(replace(TestCase[1]/@filename, '.cpp', ''), '/')[last()]"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="timestamp">
                <xsl:value-of select="format-dateTime(current-dateTime(), '[Y0001]-[M01]-[D01]T[h24]:[m01]:[s01]')"/>
            </xsl:attribute>
            <xsl:attribute name="hostname">N/A</xsl:attribute>
            <xsl:attribute name="tests">
                <xsl:value-of select="count(TestCase)"/>
            </xsl:attribute>
            <xsl:attribute name="failures">
                <xsl:value-of select="count(TestCase[OverallResultsAsserts[@failures!='0']])"/>
            </xsl:attribute>
            <xsl:attribute name="errors">0</xsl:attribute>
            <xsl:attribute name="time">
                <xsl:value-of
                        select="format-number(sum(TestCase/OverallResultsAsserts/@duration), '#.###')"/>
            </xsl:attribute>
            <properties/>
            <xsl:apply-templates/>
            <system-out/>
            <system-err/>
        </testsuite>
    </xsl:template>

    <xsl:template match="TestCase">
        <xsl:variable name="filename"
                      select="tokenize(replace(@filename, '.cpp', ''), '/')[last()]"/>
        <testcase>
            <xsl:attribute name="name">
                <xsl:value-of select="normalize-space(@name)"/>
            </xsl:attribute>
            <xsl:attribute name="classname">
                <xsl:value-of select="$binary"/>.<xsl:value-of select="$filename"/>
            </xsl:attribute>
            <xsl:attribute name="time">
                <xsl:value-of select="format-number(sum(OverallResultsAsserts/@duration), '#.###')"/>
            </xsl:attribute>
            <xsl:if test="OverallResultsAsserts/@failures > 0">
                <failure type="">
                    <xsl:attribute name="message">OverallResultsAsserts successes=<xsl:value-of select="OverallResultsAsserts/@successes"/> failures=<xsl:value-of select="OverallResultsAsserts/@failures"/></xsl:attribute>
                    <xsl:apply-templates/>
                </failure>
             </xsl:if>
        </testcase>
    </xsl:template>

    <xsl:template match="Exception">
        <xsl:text>EXCEPTION&#xA;</xsl:text>
        <xsl:value-of select="normalize-space(.)"/>
        <xsl:text>&#xA;&#xA;</xsl:text>
    </xsl:template>

    <xsl:template match="SubCase">
        <xsl:if test="current()//Expression/@success = 'false' or current()//Message/@type != 'WARNING' or current()//Message">
            <xsl:if test="@name">
                <xsl:value-of select="normalize-space(@name)"/>
                <xsl:text>&#xA;</xsl:text>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="Expression">
        <xsl:if test="@success = 'false'">
            <xsl:value-of select="@type"/>
            <xsl:text>&#xA;</xsl:text>
            <xsl:value-of select="normalize-space(.)"/>
            <xsl:text>&#xA;&#xA;</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template match="Message">
        <xsl:if test="@type != 'WARNING'">
            <xsl:value-of select="@type"/>
            <xsl:text>&#xA;</xsl:text>
            <xsl:value-of select="normalize-space(.)"/>
            <xsl:text>&#xA;&#xA;</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template match="text()"/>
</xsl:stylesheet>
