<%-- 
    Document   : query
    Created on : Dec 8, 2011, 6:34:47 AM
    Author     : spaans01
--%>

<%@taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions"%>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql"%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>

<c:if test="${param.t != ''}">
    <c:choose>
        <c:when test="${param.t == 'd'}">
            <c:set var="result_insert_sponsor" />

            <c:set var="sponsor_id" />

            <c:set var="sponsoree_id">
                <c:out value="${fn:escapeXml(param.r)}" default=""/>
            </c:set>

            <c:set var="sponsor_givenName">
                <c:out value="${fn:escapeXml(param.a)}" default=""/>
            </c:set>

            <c:set var="sponsor_surname">
                <c:out value="${fn:escapeXml(param.b)}" default=""/>
            </c:set>

            <c:set var="sponsor_mailParts" value="${fn:split(fn:escapeXml(param.c),'@')}" />

            <c:set var="sponsor_mailLocalPart">
                <c:out value="${fn:toLowerCase(sponsor_mailParts[0])}" default=""/>
            </c:set>

            <c:set var="sponsor_mailDomain">
                <c:out value="${fn:toLowerCase(sponsor_mailParts[1])}" default=""/>
            </c:set>

            <c:set var="donation_type">
                <c:out value="${fn:escapeXml(param.n)}" default=""/>
            </c:set>

            <c:set var="donation_amount">
                <c:out value="${fn:escapeXml(param.o)}" default="0"/>
            </c:set>

            <c:set var="sql_insert_sponsor">
                INSERT INTO maw.person
                (
                    surname,
                    givenName,
                    mailLocalPart,
                    mailDomain,
                    enabled,
                    creationDate
                )
                VALUES(
                    '${sponsor_surname}',
                    '${sponsor_givenName}',
                    '${sponsor_mailLocalPart}',
                    '${sponsor_mailDomain}',
                    0,
                    NOW()
                );
            </c:set>

            <sql:update var="result_insert_sponsor" dataSource="jdbc/mawdb">
                <c:out escapeXml="false" value="${sql_insert_sponsor}"/>
            </sql:update>

            <c:set var="sql_get_id_sponsor">
                SELECT id
                FROM maw.person
                WHERE (
                    surname = '${sponsor_surname}' AND
                    givenName = '${sponsor_givenName}' AND
                    mailLocalPart = '${sponsor_mailLocalPart}' AND
                    mailDomain = '${sponsor_mailDomain}'
                )
                LIMIT 1;
            </c:set>

            <sql:query var="result_get_id_sponsor" dataSource="jdbc/mawdb">
                <c:out escapeXml="false" value="${sql_get_id_sponsor}"/>
            </sql:query>

            <c:set var="sponsor_id">
                <c:out value="${result_get_id_sponsor.rows[0].id}" default=""/>
            </c:set>

            <span class="formalText">Uw donatie is </span>
            <c:choose>
                <c:when test="${sponsor_id != ''}">

                    <c:set var="sql_insert_donation">
                        INSERT INTO maw.donation
                        (
                            id_personSponsor,
                            id_personSponsoree,
                            amount,
                            donationType,
                            distance,
                            confirmed,
                            donationDate
                        )
                        VALUES(
                            '${sponsor_id}',
                            '${sponsoree_id}',
                            '${donation_amount}',
                            '${donation_type}',
                            1,
                            0,
                            NOW()
                        );
                    </c:set>

                    <sql:update var="result_insert_donation" dataSource="jdbc/mawdb">
                        <c:out escapeXml="false" value="${sql_insert_donation}"/>
                    </sql:update>

                    <span class="formalTextSuccess">Geslaagd</span>
                </c:when>
                <c:otherwise>
                    <span class="formalTextFailure">Mislukt</span>
                </c:otherwise>
            </c:choose>
        </c:when>
        <c:when test="${param.t == 'n'}">

            <c:set var="news_mailParts" value="${fn:split(fn:escapeXml(param.e),'@')}" />

            <c:set var="news_mailLocalPart">
                <c:out value="${fn:toLowerCase(news_mailParts[0])}" default=""/>
            </c:set>

            <c:set var="news_mailDomain">
                <c:out value="${fn:toLowerCase(news_mailParts[1])}" default=""/>
            </c:set>

            <c:set var="sql_insert_subscription">
                INSERT INTO maw.news
                (
                    mailLocalPart,
                    mailDomain,
                    confirmed,
                    creationDate
                )
                VALUES(
                    '${news_mailLocalPart}',
                    '${news_mailDomain}',
                    0,
                    NOW()
                );
            </c:set>

            <sql:update var="result_insert_subscription" dataSource="jdbc/mawdb">
                <c:out escapeXml="false" value="${sql_insert_subscription}"/>
            </sql:update>
                
            <span class="formalText">Uw aanmelding is </span><span class="formalTextSuccess">geslaagd</span>
        </c:when>
        <c:otherwise>
            <span class="formalTextFailure">Een onbekende fout is opgetreden</span>
        </c:otherwise>
    </c:choose>
</c:if>