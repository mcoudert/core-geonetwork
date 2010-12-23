<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
	xmlns:geonet="http://www.fao.org/geonetwork"
	xmlns:exslt="http://exslt.org/common" exclude-result-prefixes="exslt geonet">

	<!--
	hack to extract geonet URI; I know, I could have used a string constant like
	<xsl:variable name="geonetUri" select="'http://www.fao.org/geonetwork'"/>
	but this is more interesting
	-->
	<xsl:variable name="geonetNodeSet"><geonet:dummy/></xsl:variable>

	<xsl:variable name="geonetUri">
		<xsl:value-of select="namespace-uri(exslt:node-set($geonetNodeSet)/*)"/>
	</xsl:variable>

	<xsl:variable name="currTab">
		<xsl:choose>
			<xsl:when test="/root/gui/currTab"><xsl:value-of select="/root/gui/currTab"/></xsl:when>
			<xsl:otherwise>simple</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<!--
	creates a thumbnail image, possibly with a link to larger image
	-->
	<xsl:template name="thumbnail">
		<xsl:param name="metadata"/>

		<xsl:choose>

			<!-- small thumbnail -->
			<xsl:when test="$metadata/image[@type='thumbnail']">

				<xsl:choose>

					<!-- large thumbnail link -->
					<xsl:when test="$metadata/image[@type='overview']">
						<a href="javascript:popWindow('{$metadata/image[@type='overview']}')">
							<img src="{$metadata/image[@type='thumbnail']}" alt="{/root/gui/strings/thumbnail}"/>
						</a>
					</xsl:when>

					<!-- no large thumbnail -->
					<xsl:otherwise>
						<img src="{$metadata/image[@type='thumbnail']}" alt="{/root/gui/strings/thumbnail}"/>
					</xsl:otherwise>
				</xsl:choose>

			</xsl:when>

			<!-- unknown thumbnail (usually a url so limit size) -->
			<xsl:when test="$metadata/image[@type='unknown']">
				<img src="{$metadata/image[@type='unknown']}" alt="{/root/gui/strings/thumbnail}" height="180" width="180"/>
			</xsl:when>

			<!-- papermaps thumbnail -->
			<!-- FIXME
			<xsl:when test="/root/gui/paperMap and string(dataIdInfo/idCitation/presForm/PresFormCd/@value)='mapHardcopy'">
				<a href="PAPERMAPS-URL">
					<img src="{/root/gui/paperMap}" alt="{/root/gui/strings/paper}" title="{/root/gui/strings/paper}"/>
				</a>
			</xsl:when>
			-->

			<!-- no thumbnail -->
			<xsl:otherwise>
				<img src="{/root/gui/locUrl}/images/nopreview.gif" alt="{/root/gui/strings/thumbnail}"/>
			</xsl:otherwise>
		</xsl:choose>
		<br/>
	</xsl:template>

	<!--
	editor left tab
	-->
	<xsl:template name="tab">
		<xsl:param name="schema">
			<xsl:apply-templates mode="schema" select="."/>
		</xsl:param>
		<xsl:param name="tabLink"/>
		
		<table width="100%">
			<!-- Tab visibility is managed in config-gui.xml -->
			<!-- simple tab -->
			<xsl:if test="/root/gui/config/metadata-tab/simple">
				<xsl:call-template name="displayTab">
					<xsl:with-param name="tab"     select="'simple'"/>
					<xsl:with-param name="text"    select="/root/gui/strings/simpleTab"/>
					<xsl:with-param name="tabLink" select="$tabLink"/>
				</xsl:call-template>
			</xsl:if>
			
			<!--  complete tab(s) -->
			<xsl:choose>
				<!-- hide complete tab for subtemplates -->
				<xsl:when test="geonet:info[isTemplate='s']"/>
				<xsl:otherwise>
				
					<!-- metadata type-specific complete tab -->
					<xsl:variable name="schemaCompleteTabCallBack">
						<xsl:element name="{concat($schema,'CompleteTab')}"/>
						<xsl:copy-of select="/root"/>
						<xsl:element name="metadata">
							<xsl:copy-of select="."/>
						</xsl:element>
					</xsl:variable>

					<xsl:apply-templates select="exslt:node-set($schemaCompleteTabCallBack/*[1])">
						<xsl:with-param name="tabLink" select="$tabLink"/>
						<xsl:with-param name="schema" select="$schema"/>
					</xsl:apply-templates>
						
				</xsl:otherwise>
			</xsl:choose>
			
			<!-- xml tab -->
			<xsl:if test="/root/gui/config/metadata-tab/xml">
				<xsl:call-template name="displayTab">
					<xsl:with-param name="tab"     select="'xml'"/>
					<xsl:with-param name="text"    select="/root/gui/strings/xmlTab"/>
					<xsl:with-param name="tabLink" select="$tabLink"/>
				</xsl:call-template>
			</xsl:if>
		</table>
	</xsl:template>
	
	<!--
	default complete tab template - schemas that don't provide a set of
	tabs can call this from their CompleteTab callback
	-->
	<xsl:template name="completeTab">
		<xsl:param name="tabLink"/>
		
		<xsl:call-template name="displayTab">
			<xsl:with-param name="tab"     select="'metadata'"/>
			<xsl:with-param name="text"    select="/root/gui/strings/completeTab"/>
			<xsl:with-param name="tabLink" select="$tabLink"/>
		</xsl:call-template>
	</xsl:template>
	
	<!--
	shows a tab
	-->
	<xsl:template name="displayTab">
		<xsl:param name="tab"/>
		<xsl:param name="text"/>
		<xsl:param name="indent"/>
		<xsl:param name="tabLink"/>
		
		<xsl:variable name="currTab" select="/root/gui/currTab"/>
	
		<tr><td class="banner-login">
			<xsl:value-of select="$indent"/>
			
			<xsl:choose>
				<!-- not active -->
				<xsl:when test="$tabLink=''"><font class="banner-passive"><xsl:value-of select="$text"/></font></xsl:when>
				
				<!-- selected -->
				<xsl:when test="$currTab=$tab"><font class="banner-active"><xsl:value-of select="$text"/></font></xsl:when>
				
				<!-- not selected -->
				<xsl:otherwise><a class="palette" href="javascript:doTabAction('{$tabLink}','{$tab}')"><xsl:value-of select="$text"/></a></xsl:otherwise>
			</xsl:choose>
		</td></tr>
	</xsl:template>
	
</xsl:stylesheet>