<%-- 
    Document   : admin
    Created on : May 26, 2013, 5:00:00 PM
    Author     : leons
--%>

<%@taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions"%>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql"%>

<c:choose>
    <c:when test="${param.t == 'np'}">

        <c:set var="person_id">
            <c:out value="${fn:escapeXml(param.pid)}" default=""/>
        </c:set>

        <c:set var="sql_update_person">
            UPDATE maw.person
            SET enabled = 1
            WHERE id = ${person_id};
        </c:set>
            
        <sql:update var="result_update_person" dataSource="jdbc/mawdb">
            <c:out escapeXml="false" value="${sql_update_person}"/>
        </sql:update>
    </c:when>
    <c:when test="${param.t == 'nd'}">

        <c:set var="donation_id">
            <c:out value="${fn:escapeXml(param.did)}" default=""/>
        </c:set>

        <c:set var="sql_update_donation">
            UPDATE maw.donation
            SET confirmed = 1
            WHERE id = ${donation_id};
        </c:set>
            
        <sql:update var="result_update_donation" dataSource="jdbc/mawdb">
            <c:out escapeXml="false" value="${sql_update_donation}"/>
        </sql:update>
    </c:when>
    <c:when test="${param.t == 'ns'}">

        <c:set var="subscription_id">
            <c:out value="${fn:escapeXml(param.nid)}" default=""/>
        </c:set>

        <c:set var="sql_update_subscription">
            UPDATE maw.news
            SET confirmed = 1
            WHERE id = ${subscription_id};
        </c:set>
            
        <sql:update var="result_update_subscription" dataSource="jdbc/mawdb">
            <c:out escapeXml="false" value="${sql_update_subscription}"/>
        </sql:update>
    </c:when>
    <c:otherwise>
    </c:otherwise>
</c:choose>

<c:set var="sql_get_persons">
    SELECT
        p.id AS 'id',
        p.givenName AS 'givenName',
        p.surname AS 'surname'
    FROM maw.person p
    WHERE NOT(p.enabled);
</c:set>
    
<c:set var="sql_get_donations">
    SELECT
        d.id AS 'id',
        CONCAT('',pr.givenName) AS 'sponsor_givenName',
        CONCAT('',pr.surname) AS 'sponsor_surname',
        CONCAT('',pe.givenName) AS 'sponsoree_givenName',
        CONCAT('',pe.surname) AS 'sponsoree_surname',
        CONCAT('',d.donationType) AS 'donation_type',
        d.amount AS 'amount'
    FROM maw.donation d
    LEFT JOIN maw.person pr ON pr.id = d.id_personSponsor
    LEFT JOIN maw.person pe ON pe.id = d.id_personSponsoree
    WHERE NOT(d.confirmed = 1);
</c:set>
    
<c:set var="sql_get_subscriptions">
    SELECT
        n.id AS 'id',
        n.mailLocalPart,
        n.mailDomain
    FROM maw.news n
    WHERE NOT(n.confirmed);
</c:set>
    
<sql:query var="result_get_persons" dataSource="jdbc/mawdb">
    <c:out escapeXml="false" value="${sql_get_persons}" default="" />
</sql:query>
    
<sql:query var="result_get_donations" dataSource="jdbc/mawdb">
    <c:out escapeXml="false" value="${sql_get_donations}" default="" />
</sql:query>
    
<sql:query var="result_get_subscriptions" dataSource="jdbc/mawdb">
    <c:out escapeXml="false" value="${sql_get_subscriptions}" default="" />
</sql:query>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <title>- IDentity.Next - Make-A-Wish - Admin -</title>
        <link rel="shortcut icon" href="image/favicon.ico" />
        <link rel="StyleSheet" type="text/css" href="style/main.css" media="screen" />
        <script type="text/javascript" language="javascript" src="script/functions.js"></script>
    </head>

    <body onLoad="">
        <div name="screen" id="screen" class="screen">

            <div name="screenHeader" id="screenHeader" class="screenHeader">
                <img name="logoMAW" id="logoMAW" class="logoMAW" src="image/logo_MAW.png" />
                <span id="clock" class="clock"></span>
                <img name="logoIDN" id="logoIDN" class="logoIDN" src="image/logo_IDNext.png" />
            </div>

                
            <div id="screenLeft" class="screenLeft">

            </div>

            <div id="screenMain" class="screenMain">
                
                <span class="mainTitleText">Nieuw:</span><br/>
                <br/>

                <form name="personConfirm" method="POST" action="admin.jsp">
                    <input type="hidden" name="t" value="np" />
                    <span class="mainTitleText">Personen:</span>
                    <table class="ovTable">
                        <tr>
                            <td class="ovHeaderCell"><span class="formalText">OK</span></td>
                            <td class="ovHeaderCell"><span class="formalText">Voornaam</span></td>
                            <td class="ovHeaderCell"><span class="formalText">Achternaam</span></td>
                        </tr>
                        <c:forEach var="row" items="${result_get_persons.rows}">
                            <tr>
                                <td><input type="radio" name="pid" value="<c:out value="${row.id}" default="" />" /></td>
                                <td class="ovCell"><span class="formalText"><c:out value="${row.givenName}" default="" /></span></td>
                                <td class="ovCell"><span class="formalText"><c:out value="${row.surname}" default="" /></span></td>
                            </tr>
                        </c:forEach>
                    </table>
                    <button type="submit" onClick="">Bevestig</button>
                </form>
                <br/>

                <form name="donationConfirm" method="POST" action="admin.jsp">
                    <input type="hidden" name="t" value="nd" />
                    <span class="mainTitleText">Donaties:</span>
                    <table class="ovTable">
                        <tr>
                            <td colspan="2" class="ovHeaderCell"></td>
                            <td colspan="2" class="ovHeaderCell"><span class="formalText">Sponsor</span></td>
                            <td colspan="2" class="ovHeaderCell"><span class="formalText">Gesponsorde</span></td>
                            <td colspan="2" class="ovHeaderCell"><span class="formalText"></span></td>
                        </tr>
                        <tr>
                            <td class="ovHeaderCell"><span class="formalText">OK</span></id>
                            <td class="ovHeaderCell"><span class="formalText">Voornaam</span></td>
                            <td class="ovHeaderCell"><span class="formalText">Achternaam</span></td>
                            <td class="ovHeaderCell"><span class="formalText">Voornaam</span></td>
                            <td class="ovHeaderCell"><span class="formalText">Achternaam</span></td>
                            <td class="ovHeaderCell"><span class="formalText">Type donatie</span></td>
                            <td class="ovHeaderCell"><span class="formalText">Bedrag</span></td>
                        </tr>
                        <c:forEach var="row" items="${result_get_donations.rows}">
                            <tr>
                                <td><input type="radio" name="did" value="<c:out value="${row.id}" default="" />" /></td>
                                <td class="ovCell"><span class="formalText"><c:out value="${row.sponsor_givenName}" default="" /></span></td>
                                <td class="ovCell"><span class="formalText"><c:out value="${row.sponsor_surname}" default="" /></span></td>
                                <td class="ovCell"><span class="formalText"><c:out value="${row.sponsoree_givenName}" default="" /></span></td>
                                <td class="ovCell"><span class="formalText"><c:out value="${row.sponsoree_surname}" default="" /></span></td>
                                <td class="ovCell"><span class="formalText"><c:out value="${row.donation_type}" default="" /></span></td>
                                <td class="ovCell"><span class="formalText">&euro;<c:out value="${row.amount}" default="" /></span></td>            
                            </tr>
                        </c:forEach>
                    </table>
                    <button type="submit" onClick="">Bevestig</button>
                </form>
                <br/>

                <form name="newsletterConfirm" method="POST" action="admin.jsp">
                    <input type="hidden" name="t" value="ns" />
                    <span class="mainTitleText">Niewsbrief aanmeldingen:</span>
                    <table class="ovTable">
                        <tr class="">
                            <td class="ovHeaderCell"><span class="formalText">OK</span></td>
                            <td class="ovHeaderCell"><span class="formalText">E-mail adres</span></td>
                        </tr>

                        <c:forEach var="row" items="${result_get_subscriptions.rows}">
                            <tr>
                                <td><input type="radio" name="nid" value="<c:out value="${row.id}" default="" />" /></td>
                                <td class="ovCell"><span class="formalText"><c:out value="${row.maiLLocalPart}" default="" />@<c:out value="${row.mailDomain}" default="" /></span></td>
                            </tr>
                        </c:forEach>
                    </table>
                    <button type="submit" onClick="">Bevestig</button>
                </form>
                <br/>
                
            </div>
            
            <div id="screenRight" class="screenRight">

            </div>
                    
            
            <div id="screenFooter" class="screenFooter">

            </div>
        </div>

    </body>
</html>
