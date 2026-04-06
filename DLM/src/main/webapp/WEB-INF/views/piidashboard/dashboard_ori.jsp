<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<!-- Begin Page Content -->
<div class="card shadow m-1 " style="height:818px" id="piidatabaselist">

    <!-- Begin Page Content -->
    <div class="container-fluid">
        <!-- Page Heading -->
        <!-- <h1 class="h6 mb-2 text-gray-800">Charts</h1> -->
        <!-- <p class="mb-2">Chart.js is a third party plugin that is used to generate the charts in this theme.</p> -->
        <!-- Content Row -->
        <div class="row mt-4 mb-0">
            <div class="col-xl-4 col-lg-5">
                <div class="card shadow mb-2">
                    <!-- Card Header - Dropdown -->
                    <div class="card-header py-1">
                        <h6 class="m-0 font-weight-bold text-primary"><spring:message code="etc.cumulativePurgeStatus" text="Cumulative Customer Purge Status"/>
                        </h6>
                    </div>
                    <!-- Card Body -->
                    <div class="card-body" style="height: 360px">
                        <div class="chart-pie pt-2" >
                            <canvas id="ChartSum"></canvas>
                        </div>

                    </div>
                </div>
            </div>
            <div class="col-xl-4 col-lg-5">
                <div class="card shadow mb-2">
                    <!-- Card Header - Dropdown -->
                    <div class="card-header py-1">
                        <h6 class="m-0 font-weight-bold text-primary"><spring:message code="etc.dailyPurgeStatus" text="Daily Customer Purge Status"/>
                        </h6>
                    </div>
                    <!-- Card Body -->
                    <div class="card-body" style="height: 360px">
                        <div class="chart-pie pt-2" >
                            <canvas id="ChartDaily"></canvas>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-xl-4 col-lg-5">
                <div class="card shadow mb-2">
                    <!-- Card Header - Dropdown -->
                    <div class="card-header py-1">
                        <h6 class="m-0 font-weight-bold text-primary"><spring:message code="etc.monthlyPurgeStatus" text="Monthly Customer Purge Status"/>
                        </h6>
                    </div>
                    <!-- Card Body -->
                    <div class="card-body" style="height: 360px">
                        <div class="chart-pie pt-2" >
                            <canvas id="ChartMonthly"></canvas>
                        </div>

                    </div>
                </div>
            </div>

        </div> <!-- <div class="row mt-2" > -->
        <!-- Content Row -->
        <div class="row mt-2 mb-0">

            <div class="col-xl-4 col-lg-5">
                <div class="card shadow mb-2">
                    <!-- Card Header - Dropdown -->
                    <div class="card-header py-1">
                        <h6 class="m-0 font-weight-bold text-primary"><spring:message code="etc.jobExecutionStatus" text="Job Execution Status"/>
                        </h6>
                    </div>
                    <!-- Card Body -->
                    <div class="card-body">
                        <div class="chart-pie pt-2">
                            <canvas id="JobResultPieChart"></canvas>
                        </div>

                    </div>
                </div>

            </div>

            <div class="col-xl-4 col-lg-5">
                <div class="card shadow mb-2">
                    <!-- Card Header - Dropdown -->
                    <div class="card-header py-1">
                        <h6 class="m-0 font-weight-bold text-primary"><spring:message code="etc.physicalPurgeStatus" text="Physical Doc. Purge Status"/>
                        </h6>
                    </div>
                    <!-- Card Body -->
                    <div class="card-body">
                        <div class="chart-pie pt-2">
                            <canvas id="realDocMonthly"></canvas>
                        </div>

                    </div>
                </div>
            </div>
            <div class="col-xl-4 col-lg-5">
                <div class="card shadow mb-2">
                    <!-- Card Header - Dropdown -->
                    <div class="card-header py-1">
                        <h6 class="m-0 font-weight-bold text-primary"><spring:message code="etc.notice" text="Notice"/>
                        </h6>
                    </div>
                    <!-- Card Body -->
                    <div class="card-body">
                        <div class="chart-pie pt-2">
                            <table style="border-collapse:collapse;border:none">
                                <tr style="border-collapse:collapse;border:none">
                                    <td style="border-collapse:collapse;border:none"><c:out value="${notice1}"/></td>
                                </tr>
                                <tr style="border-collapse:collapse;border:none">
                                    <td style="border-collapse:collapse;border:none"><c:out value="${notice2}"/></td>
                                </tr>
                                <tr style="border-collapse:collapse;border:none">
                                    <td style="border-collapse:collapse;border:none"><c:out value="${notice3}"/></td>
                                </tr>
                                <tr style="border-collapse:collapse;border:none">
                                    <td style="border-collapse:collapse;border:none"><c:out value="${notice4}"/></td>
                                </tr>
                                <tr style="border-collapse:collapse;border:none">
                                    <td style="border-collapse:collapse;border:none"><c:out value="${notice5}"/></td>
                                </tr>
                            </table>
                        </div>

                    </div>
                </div>
            </div>
        </div> <!-- <div class="row mt-2" > -->


    </div>
    <!-- /.container-fluid -->


</div>
<!-- <div class="card shadow mb-1"> -->


<script type="text/javascript">

    $(function () {
        $("#menupath").html("<i class='far fa-chart-bar'></i> <spring:message code="memu.dashboard" text="Dashboard"/>");

    });
    $(document).ready(function () {

        var result = '<c:out value="${result}"/>';
        checkResultModal(result);
        history.replaceState({}, null, null);

    });


    movePage = function (pageNo) {
        searchAction(pageNo);
        /* 	alert("/piidatabase/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
            $('#content_home').load("/piidatabase/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search); */
    }

    searchAction = function (pageNo, serchkeyno) {
        var pagenum = $('#searchForm [name="pagenum"]').val();
        var amount = $('#searchForm [name="amount"]').val();
        var search1 = $('#searchForm [name="db"]').val();
        var search2 = $('#searchForm [name="db"]').val();
        var url_search = "";
        var url_view = "";
        if (isEmpty(serchkeyno)) {
            url_view = "list?";
        } else {
            url_view = "get?" + serchkeyno + "&";
        }
        if (isEmpty(pagenum)) pagenum = 1;
        if (!isEmpty(pageNo)) pagenum = pageNo;
        if (isEmpty(amount)) amount = 100;
        if (!isEmpty(search1)) {
            url_search += "&search1=" + search1;
        }
        if (!isEmpty(search2)) {
            url_search += "&search2=" + search2;
        }

        //alert("/piidatabase/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
        ingShow(); $.ajax({
            type: "GET",
            url: "/piidatabase/" + url_view + "pagenum=" + pagenum + "&amount=" + amount + url_search,
            dataType: "html",
            error: function (request, error) { ingHide();
                $("#errormodalbody").html(request.responseText);
                $("#errormodal").modal("show");
            },
            success: function (data) { ingHide();
                $('#content_home').html(data);
            }
        });

    }

</script>
<!-- Bootstrap core JavaScript-->
<script src="/resources/vendor/jquery/jquery.min.js"></script>
<script src="/resources/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>

<!-- Core plugin JavaScript-->
<script src="/resources/vendor/jquery-easing/jquery.easing.min.js"></script>

<!-- Custom scripts for all pages-->
<script src="/resources/js/sb-admin-2.min.js"></script>

<!-- Page level plugins -->
<script src="/resources/vendor/chart.js/Chart.min.js"></script>


<script>
    $(function(){
        <sec:authentication property="principal.member.userid" var="userid"/>
        <c:if test="${userid ne 'admin' }">
        if("<c:out value='${needtochangepwd}'/>" == "INI"){
            if(!confirm("<spring:message code="etc.pwdfirst" text="Your password is in the reset state. Would you like to change it now?"/>")){
            }else{
                searchAction_pwd("<c:out value='${userid}'/>");
            }
        }
        if("<c:out value='${needtochangepwd}'/>" == "EXPIRED"){
            if(!confirm("<spring:message code="etc.pwdreset" text="Your password has expired 6 months after the last change. Would you like to change it now?"/>")){
            }else{
                searchAction_pwd("<c:out value='${userid}'/>");
            }
        }
        </c:if>
    });
    searchAction_pwd = function(userid) {

        var url_view = "modify?userid="+userid+"&pagenum=1&amount=100";

        ingShow(); $.ajax({
            type: "GET",
            url : "/piimember/"+url_view,
            dataType : "html",
            error: function(request, error){ ingHide();
                $("#errormodalbody").html(request.responseText);$("#errormodal").modal("show");
            },
            success: function(data){ ingHide();
                $('#content_home').html(data);
            }
        });

    }
</script>
<!-- Page level custom scripts -->
<script>
    //Pie Chart Example
    var ctx = document.getElementById("JobResultPieChart");
    var JobResultPieChart = new Chart(ctx, {
        type: 'doughnut',
        data: {
            labels: ["Wait", "OK", "Running", "Error", "Recovered"],
            datasets: [{
                data: [<c:out value="${jobresultlist.wait}"/>, <c:out value="${jobresultlist.ok}"/>, <c:out value="${jobresultlist.run}"/>, <c:out value="${jobresultlist.ko}"/>, <c:out value="${jobresultlist.recovered}"/>],
                backgroundColor: ['#6C757D', '#28A745', '#007BFF', '#DC3545', '#36B9CC'],
                hoverBackgroundColor: ['#6C757D', '#28A745', '#007BFF', '#DC3545', '#36B9CC'],
                hoverBorderColor: "rgba(234, 236, 244, 1)",
            }],
        },
        options: {
            maintainAspectRatio: true,
            tooltips: {
                backgroundColor: "rgb(255,255,255)",
                bodyFontColor: "#858796",
                borderColor: '#dddfeb',
                borderWidth: 1,
                xPadding: 15,
                yPadding: 15,
                displayColors: true,
                caretPadding: 10,
            },
            legend: {
                display: true
            },
            cutoutPercentage: 50,
        },
    });

</script>

<script type="text/javascript">
    var ym11 = "<c:out value="${custstatsumlist.ym_11}"/>";
    var ym10 = "<c:out value="${custstatsumlist.ym_10}"/>";
    var ym9 = "<c:out value="${custstatsumlist.ym_9}"/>";
    var ym8 = "<c:out value="${custstatsumlist.ym_8}"/>";
    var ym7 = "<c:out value="${custstatsumlist.ym_7}"/>";
    var ym6 = "<c:out value="${custstatsumlist.ym_6}"/>";
    var ym5 = "<c:out value="${custstatsumlist.ym_5}"/>";
    var ym4 = "<c:out value="${custstatsumlist.ym_4}"/>";
    var ym3 = "<c:out value="${custstatsumlist.ym_3}"/>";
    var ym2 = "<c:out value="${custstatsumlist.ym_2}"/>";
    var ym1 = "<c:out value="${custstatsumlist.ym_1}"/>";
    var ym0 = "<c:out value="${custstatsumlist.ym_0}"/>";
    let sumcolorlist = [
        <c:forEach items="${custstatlistdaily}" var="month">
        'rgba(86, 121, 224, 0.8)',
        </c:forEach>
    ];
    var contextSum = document
        .getElementById('ChartSum')
        .getContext('2d');
    var myChartSum = new Chart(contextSum, {
        type: 'line', // 차트의 형태
        data: { // 차트에 들어갈 데이터
            labels: [ym11, ym10, ym9, ym8, ym7, ym6, ym5, ym4, ym3, ym2, ym1, ym0],
            datasets: [
                { //데이터
                    label: '<spring:message code="etc.cumulativePurgeCustomerCount" text="Cumulative Purged Customer Count"/>', //차트 제목
                    fill: false, // line 형태일 때, 선 안쪽을 채우는지 안채우는지
                    data: [<c:out value="${custstatsumlist.cnt_11}"/>, <c:out value="${custstatsumlist.cnt_10}"/>, <c:out value="${custstatsumlist.cnt_9}"/>, <c:out value="${custstatsumlist.cnt_8}"/>, <c:out value="${custstatsumlist.cnt_7}"/>, <c:out value="${custstatsumlist.cnt_6}"/>, <c:out value="${custstatsumlist.cnt_5}"/>, <c:out value="${custstatsumlist.cnt_4}"/>, <c:out value="${custstatsumlist.cnt_3}"/>, <c:out value="${custstatsumlist.cnt_2}"/>, <c:out value="${custstatsumlist.cnt_1}"/>, <c:out value="${custstatsumlist.cnt_0}"/>],
                    backgroundColor: sumcolorlist,
                    borderColor: sumcolorlist,
                    borderWidth: 1 //경계선 굵기
                }
            ]
        },
        options: {
            scales: {
                yAxes: [
                    {
                        ticks: {
                            beginAtZero: true,
                            callback: function(value, index, values) {
                                // value는 y 축의 각 값입니다.
                                // value를 포맷에 맞게 변경합니다.
                                return new Intl.NumberFormat().format(value);
                            }
                        }
                    }
                ]
            }
        }
    });
</script>
<script type="text/javascript">
    let monlist = [
        <c:forEach items="${custstatlistdaily}" var="month">
        '<c:out value="${month.mon}" />',
        </c:forEach>
    ];
    let policy2list = [
        <c:forEach items="${custstatlistdaily}" var="month">
        '<c:out value="${month.archive_cnt2}" />',
        </c:forEach>
    ];
    let policy3list = [
        <c:forEach items="${custstatlistdaily}" var="month">
        '<c:out value="${month.archive_cnt3}" />',
        </c:forEach>
    ];
    let policy2colorlist = [
        <c:forEach items="${custstatlistdaily}" var="month">
        'rgba(224, 188, 85, 1)',
        </c:forEach>
    ];
    let policy3colorlist = [
        <c:forEach items="${custstatlistdaily}" var="month">
        'rgba(86, 121, 224, 0.8)',
        </c:forEach>
    ];
    var context = document
        .getElementById('ChartDaily')
        .getContext('2d');
    var myChart = new Chart(context, {
        type: 'bar', // 차트의 형태
        data: { // 차트에 들어갈 데이터
            labels: monlist,
            datasets: [
                { //데이터
                    label: '<spring:message code="etc.rejectCancel" text="Customers who rejected or canceled consultations"/>', //차트 제목
                    fill: false, // line 형태일 때, 선 안쪽을 채우는지 안채우는지
                    data: policy2list,//[21,19,25,20,23,26,25 //x축 label에 대응되는 데이터 값]
                    backgroundColor: policy2colorlist,
                    borderColor: policy2colorlist,
                    borderWidth: 1 //경계선 굵기
                },
                { //데이터
                    label: '<spring:message code="etc.noActviceTransactions" text="Customers with no active transactions"/>', //차트 제목
                    fill: false, // line 형태일 때, 선 안쪽을 채우는지 안채우는지
                    data: policy3list, //[121,119,125,120,123,126,125 //x축 label에 대응되는 데이터 값]
                    backgroundColor: policy3colorlist,
                    borderColor: policy3colorlist,
                    borderWidth: 1 //경계선 굵기
                }
            ]
        },
        options: {
            scales: {
                yAxes: [
                    {
                        ticks: {
                            beginAtZero: true,
                            callback: function(value, index, values) {
                                // value는 y 축의 각 값입니다.
                                // value를 포맷에 맞게 변경합니다.
                                return new Intl.NumberFormat().format(value);
                            }
                        }
                    }
                ]
            }
        }
    });
</script>

<script type="text/javascript">
    monlist = [
        <c:forEach items="${custstatlistmonthly}" var="month">
        '<c:out value="${month.mon}" />',
        </c:forEach>
    ];
    policy2list = [
        <c:forEach items="${custstatlistmonthly}" var="month">
        '<c:out value="${month.archive_cnt2}" />',
        </c:forEach>
    ];
    policy3list = [
        <c:forEach items="${custstatlistmonthly}" var="month">
        '<c:out value="${month.archive_cnt3}" />',
        </c:forEach>
    ];
    policy2colorlist = [
        <c:forEach items="${custstatlistmonthly}" var="month">
        'rgba(224, 188, 85, 1)',
        </c:forEach>
    ];
    policy3colorlist = [
        <c:forEach items="${custstatlistmonthly}" var="month">
        'rgba(86, 121, 224, 0.8)',
        </c:forEach>
    ];
    var contextMonthly = document
        .getElementById('ChartMonthly')
        .getContext('2d');
    var myChartMonthly = new Chart(contextMonthly, {
        type: 'bar', // 차트의 형태
        data: { // 차트에 들어갈 데이터
            labels: monlist,
            datasets: [
                { //데이터
                    label: '<spring:message code="etc.rejectCancel" text="Customers who rejected or canceled consultations"/>', //차트 제목
                    fill: false, // line 형태일 때, 선 안쪽을 채우는지 안채우는지
                    data: policy2list,//[21,19,25,20,23,26,25 //x축 label에 대응되는 데이터 값]
                    backgroundColor: policy2colorlist,
                    borderColor: policy2colorlist,
                    borderWidth: 1 //경계선 굵기
                },
                { //데이터
                    label: '<spring:message code="etc.noActviceTransactions" text="Customers with no active transactions"/>', //차트 제목
                    fill: false, // line 형태일 때, 선 안쪽을 채우는지 안채우는지
                    data: policy3list, //[121,119,125,120,123,126,125 //x축 label에 대응되는 데이터 값]
                    backgroundColor: policy3colorlist,
                    borderColor: policy3colorlist,
                    borderWidth: 1 //경계선 굵기
                }
            ]
        },
        options: {
            scales: {
                yAxes: [
                    {
                        ticks: {
                            beginAtZero: true,
                            callback: function(value, index, values) {
                                // value는 y 축의 각 값입니다.
                                // value를 포맷에 맞게 변경합니다.
                                return new Intl.NumberFormat().format(value);
                            }
                        }
                    }
                ]
            }
        }
    });
</script>

<script type="text/javascript">
    monlist = [
        <c:forEach items="${realdocstatlistmonthly}" var="month">
        '<c:out value="${month.mon}" />',
        </c:forEach>
    ];
    let acountlist = [
        <c:forEach items="${realdocstatlistmonthly}" var="month">
        '<c:out value="${month.acount}" />',
        </c:forEach>
    ];
    let ncountlist = [
        <c:forEach items="${realdocstatlistmonthly}" var="month">
        '<c:out value="${month.ncount}" />',
        </c:forEach>
    ];
    let ycountlist = [
        <c:forEach items="${realdocstatlistmonthly}" var="month">
        '<c:out value="${month.ycount}" />',
        </c:forEach>
    ];
    let acountcolorlist = [
        <c:forEach items="${realdocstatlistmonthly}" var="month">
        'rgba(86, 121, 224, 0.3)',
        </c:forEach>
    ];
    let ncountcolorlist = [
        <c:forEach items="${realdocstatlistmonthly}" var="month">
        'rgba(220, 53, 69, 0.3)',
        </c:forEach>
    ];
    let ycountcolorlist = [
        <c:forEach items="${realdocstatlistmonthly}" var="month">
        'rgba(40, 167, 69, 0.3)',
        </c:forEach>
    ];
    var contextMonthly = document
        .getElementById('realDocMonthly')
        .getContext('2d');
    var myChartMonthly = new Chart(contextMonthly, {
        type: 'bar', // 차트의 형태
        data: { // 차트에 들어갈 데이터
            labels: monlist,
            datasets: [
                { //데이터
                    label: '<spring:message code="etc.real_doc_del_target" text="Physical Doc. Purging Target Count"/>', //차트 제목
                    fill: false, // line 형태일 때, 선 안쪽을 채우는지 안채우는지
                    data: acountlist,//[21,19,25,20,23,26,25 //x축 label에 대응되는 데이터 값]
                    backgroundColor: acountcolorlist,
                    borderColor: acountcolorlist,
                    borderWidth: 1 //경계선 굵기
                },
                { //데이터
                    label: '<spring:message code="etc.real_doc_del_complete" text="Purging Not Completed"/>', //차트 제목
                    fill: false, // line 형태일 때, 선 안쪽을 채우는지 안채우는지
                    data: ncountlist, //[121,119,125,120,123,126,125 //x축 label에 대응되는 데이터 값]
                    backgroundColor: ncountcolorlist,
                    borderColor: ncountcolorlist,
                    borderWidth: 1 //경계선 굵기
                },
                { //데이터
                    label: '<spring:message code="etc.real_doc_del_not_complete" text="Purging Completed"/>', //차트 제목
                    fill: false, // line 형태일 때, 선 안쪽을 채우는지 안채우는지
                    data: ycountlist, //[121,119,125,120,123,126,125 //x축 label에 대응되는 데이터 값]
                    backgroundColor: ycountcolorlist,
                    borderColor: ycountcolorlist,
                    borderWidth: 1 //경계선 굵기
                }
            ]
        },
        options: {
            scales: {
                yAxes: [
                    {
                        ticks: {
                            beginAtZero: true,
                            callback: function(value, index, values) {
                                // value는 y 축의 각 값입니다.
                                // value를 포맷에 맞게 변경합니다.
                                return new Intl.NumberFormat().format(value);
                            }
                        }
                    }
                ]
            }
        }
    });
</script>