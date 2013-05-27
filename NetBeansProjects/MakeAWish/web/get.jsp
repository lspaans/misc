<%-- 
    Document   : get
    Created on : May 23, 2013, 8:38:43 PM
    Author     : leons
--%>

<%@taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions"%>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql"%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>

<c:set var="sql_get_random_donation">
    SELECT
            CONCAT('',pr.givenName) AS 'sponsor_givenName',
            CONCAT('',pe.givenName) AS 'sponsoree_givenName',
            CONCAT('',d.donationType) AS 'donation_type',
            d.amount AS 'amount'
    FROM maw.donation d
    LEFT JOIN maw.person pr ON pr.id = d.id_personSponsor
    LEFT JOIN maw.person pe ON pe.id = d.id_personSponsoree
    WHERE (
            d.confirmed =1 AND
            pr.enabled = 1 AND
            pe.enabled = 1
    )
    ORDER BY RAND()
    LIMIT 0,1;
</c:set>

<sql:query var="result_get_random_donation" dataSource="jdbc/mawdb">
    <c:out escapeXml="false" value="${sql_get_random_donation}" default="" />
</sql:query>

<c:set var="sponsor_givenName">
    <c:out value="${result_get_random_donation.rows[0].sponsor_givenName}" default=""/>
</c:set>
    
<c:set var="sponsoree_givenName">
    <c:out value="${result_get_random_donation.rows[0].sponsoree_givenName}" default=""/>
</c:set>

<c:set var="donation_type">
    <c:out value="${result_get_random_donation.rows[0].donation_type}" default=""/>
</c:set>
    
<c:set var="amount">
    <c:out value="${result_get_random_donation.rows[0].amount}" default=""/>
</c:set>

<span class="formalText">
    <c:if test="${sponsor_givenName != '' and sponsoree_givenName != ''  and donation_type != '' and amount != ''}">
        <c:out value="${sponsor_givenName}" /> sponsort <c:out value="${sponsoree_givenName}" /> voor &euro;<c:out value="${amount}" />
        <c:if test="${donation_type == 'distance'}">
                per kilometer!
        </c:if>
    </c:if>
</span>


