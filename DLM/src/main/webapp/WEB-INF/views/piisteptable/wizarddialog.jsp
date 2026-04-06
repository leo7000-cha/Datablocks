<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<link rel="stylesheet" href="/resources/css/piijob-refactor.css">

<!-- Begin Page Content -->
<div id=steptablemodifydilogcontent>
<div class="card m-0" style="height: 670px;width: 1100px; border: none; box-shadow: none;">

<div class="wizard-search-header" style="width:100%; padding: 10px 15px; background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%); border-bottom: 1px solid #e2e8f0;">
		<form style="margin: 0; padding: 0;" role="form" id=searchForm_wizard>
			<input type='hidden' name='pagenum'	value='<c:out value="${pageMaker.cri.pagenum}"/>'>
			<input type='hidden' name='amount'	value='<c:out value="${pageMaker.cri.amount}"/>'>
			<input type='hidden' name='search1' value='<c:out value="${pageMaker.cri.search1}"/>'>
			<input type='hidden' name='search2' value='<c:out value="${pageMaker.cri.search2}"/>'>
			<input type='hidden' name='search3' value='<c:out value="${pageMaker.cri.search3}"/>'>
			<div class="d-flex align-items-center justify-content-between">
				<div class="d-flex align-items-center" style="gap: 20px;">
					<div class="d-flex align-items-center" style="gap: 8px;">
						<label class="mb-0" style="font-size: 0.75rem; font-weight: 600; color: #475569; min-width: 35px;">DB</label>
						<input type=text class="form-control form-control-sm wizard-input"
							style="height: 26px; width: 120px; font-size: 0.75rem; background: #fff; border: 1px solid #cbd5e1; border-radius: 4px;"
							name="search4" id="search4"
							onkeypress="if (event.keyCode === 13) {event.preventDefault();SearchTableAction_wzd(); }"
							value='<c:out value="${pageMaker.cri.search4}"/>' readonly>
					</div>
					<div class="d-flex align-items-center" style="gap: 8px;">
						<label class="mb-0" style="font-size: 0.75rem; font-weight: 600; color: #475569; min-width: 45px;">Owner</label>
						<input type=text class="form-control form-control-sm wizard-input"
							style="height: 26px; width: 140px; font-size: 0.75rem; background: #fff; border: 1px solid #cbd5e1; border-radius: 4px;"
							name="search5" id="search5"
							onkeypress="if (event.keyCode === 13) {event.preventDefault();SearchTableAction_wzd(); }"
							value='<c:out value="${pageMaker.cri.search5}"/>' readonly>
					</div>
					<div class="d-flex align-items-center" style="gap: 8px;">
						<label class="mb-0" style="font-size: 0.75rem; font-weight: 600; color: #475569; min-width: 40px;">Table</label>
						<input type=text class="form-control form-control-sm wizard-input"
							style="height: 26px; width: 180px; font-size: 0.75rem; background: #fff; border: 1px solid #cbd5e1; border-radius: 4px;"
							name="search6" id="search6"
							onkeypress="if (event.keyCode === 13) {event.preventDefault();SearchTableAction_wzd(); }"
							value='<c:out value="${pageMaker.cri.search6}"/>' readonly>
					</div>
				</div>
				<div>
					<button data-oper='applywizardresult' class="btn-wizard-apply" id="btnWizardApply" disabled
							style="opacity:0.4; cursor:not-allowed;">
						<i class="fas fa-check"></i> Apply
					</button>
				</div>
			</div>
		</form>
	</div>
	<div class="wizard-info-bar" style="padding: 8px 15px; background: #fff; border-bottom: 1px solid #e2e8f0; display: flex; gap: 30px;">
		<div class="d-flex align-items-center" style="gap: 8px;">
			<c:choose>
				<c:when test="${piistep.steptype eq 'GEN_KEYMAP'}">
					<span style="font-size: 0.72rem; font-weight: 600; color: #7c3aed;"><i class="fas fa-key mr-1"></i>Keymap's KEY:</span>
					<span id=wizard_selectcol style="font-size: 0.72rem; color: #334155; font-weight: 500;"><c:out value="${piisteptable.key_cols}"/></span>
					<input type='hidden' id='selectedKeynameKr' value='<c:out value="${piisteptable.pk_col}"/>' >
				</c:when>
				<c:otherwise>
				</c:otherwise>
			</c:choose>
		</div>
		<div class="d-flex align-items-center" style="gap: 8px;">
			<span style="font-size: 0.72rem; font-weight: 600; color: #0891b2;"><i class="fas fa-link mr-1"></i>Join columns:</span>
			<span id=wizard_wherecol style="font-size: 0.72rem; color: #334155; font-weight: 500;"><c:out value="${piisteptable.where_col}"/></span>
		</div>
	</div>
	<div class="mt-0 p-1" style="width:100%; display: flex; gap: 8px;">
	<div class="wizard-table-container" style="flex: 1;">
		<table class="wizard-compact-table wizard-header-table" id="listTable_dialog_header">
			<thead>
				<tr>
					<c:choose>
						<c:when test="${piistep.steptype eq 'GEN_KEYMAP'}">
							<th style="width: 45px;">KEY</th>
							<th style="width: 45px;">JOIN</th>
						</c:when>
						<c:otherwise>
							<th style="width: 45px;">JOIN</th>
						</c:otherwise>
					</c:choose>
					<th class="th-hidden">DB</th>
					<th class="th-hidden">OWNER</th>
					<th class="th-hidden">TABLE_NAME</th>
					<th>COLUMN</th>
					<th>COLUMN(KR)</th>
					<th class="th-hidden">SEQ</th>
					<th style="width: 40px;">PK</th>
					<th style="width: 90px;">DATATYPE</th>
					<th style="width: 100px;">PIITYPE</th>
					<th style="width: 55px;">IDX</th>
				</tr>
			</thead>
		</table>
		<div class="wizard-table-wrapper">
			<table class="wizard-compact-table" id="listTable_dialog">
				<tbody>
					<c:forEach items="${piitablelist}" var="piitable">
					<tr>
						<c:choose>
							<c:when test="${piistep.steptype eq 'GEN_KEYMAP'}">
								<td class="text-center" style="width: 45px;"><input type="checkbox" class="wizard-checkbox" ${piisteptable.key_cols.contains(piitable.column_name) ? "CHECKED" : ""} name="checkselectcol" onClick="clickCheckSelectCol();"></td>
							</c:when>
							<c:otherwise>
								<input type="hidden" ${piisteptable.where_col.contains(piitable.column_name) ? "CHECKED" : ""} name="checkselectcol" onClick="clickCheckSelectCol();">
							</c:otherwise>
						</c:choose>
						<td class="text-center" style="width: 45px;"><input type="checkbox" class="wizard-checkbox" ${piisteptable.where_col.contains(piitable.column_name) ? "CHECKED" : ""} name="checkwherecol" onClick="clickCheckWhereCol();"></td>
						<td class="td-hidden"><c:out value="${piitable.db}"/></td>
						<td class="td-hidden"><c:out value="${piitable.owner}"/></td>
						<td class="td-hidden"><c:out value="${piitable.table_name}"/></td>
						<td><c:out value="${piitable.column_name}"/></td>
						<td><c:out value="${piitable.comments}"/></td>
						<td class="td-hidden"><c:out value="${piitable.column_id}"/></td>
						<td class="text-center" style="width: 40px;"><c:out value="${piitable.pk_yn}"/></td>
						<td style="width: 90px;"><c:out value="${piitable.data_type}"/></td>
						<td style="width: 100px;"><c:forEach var="item" items="${listlkPiiScrType}"><c:if test="${piitable.piitype eq item.piicode}"><c:out value="${item.piitypename}" /></c:if></c:forEach></td>
						<td class="text-center" style="width: 55px;"><c:forEach var="idx" items="${indexInfoMap[piitable.column_name]}"><span class="idx-badge idx-color-${indexColorMap[idx.name]}" title="${idx.name} (pos: ${idx.pos})">${idx.pos}</span></c:forEach></td>
					</tr>
					</c:forEach>
				</tbody>
			</table>
		</div>
	</div>
	<div class="wizard-table-container" style="flex: 0.8;">
		<table class="wizard-compact-table wizard-header-table" id="listKeymap_dialog_header">
			<thead>
				<tr>
					<th style="width: 40px;"></th>
					<th>KEY_COLS</th>
					<th>KEY_NAME</th>
					<th><spring:message code="etc.keyname_desc" text="Key Desc"/></th>
				</tr>
			</thead>
		</table>
		<div class="wizard-table-wrapper">
			<table class="wizard-compact-table" id="listKeymap_dialog_table">
				<tbody id=listKeymap_dialog>
				<c:forEach items="${piikeymaplist}" var="piikeymap">
					<c:if test="${not fn:endsWith(piikeymap.key_name, '_ETC')}">
						<tr>
							<td class="text-center" style="width: 40px;">
								<input type="radio" name="keymapradio" class="wizard-radio"
									${piisteptable.where_key_name == piikeymap.key_name ? "CHECKED" : ""}
									onClick="clickRadio();">
							</td>
							<td><c:out value="${piikeymap.key_cols}"/></td>
							<td><c:out value="${piikeymap.key_name}"/></td>
							<td><c:out value="${piikeymap.pk_col}"/></td>
						</tr>
					</c:if>
				</c:forEach>
				</tbody>
			</table>
		</div>
	</div>
</div>

</div>  <!-- <div class="card shadow m-1" style="height: 670px;width: 1100px;">-->
</div>  <!-- <div id=steptablemodifydilogcontent>-->



<!-- Bootstrap core JavaScript-->
 <script src="/resources/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>

 <!-- Core plugin JavaScript-->
 <script src="/resources/vendor/jquery-easing/jquery.easing.min.js"></script>

 <!-- Custom scripts for all pages-->
 <script src="/resources/js/sb-admin-2.min.js"></script>

<script type="text/javascript">  

$(document).ready(function(){
		validateWizardApply();
	});

</script>

<script type="text/javascript">

function checkAll() {
	$('#listKeymap_dialog tr').each(function() {
   		var tr = $(this);
	 	var td = tr.children();
 		td.css("background-color", "#FFFFFF");
 		td.css("color", "#3B3B3B");
 		td.css("font-weight", "normal");
	});
}
function clickCheckWhereCol() {

	var rowData = new Array();
	var tdArr = new Array();
	var checkbox = $("input[name=checkwherecol]:checked");
	var checkCnt = 0;        //체크된 체크박스의 개수
	var checkLast = '';      //체크된 체크박스 중 마지막 체크박스의 인덱스를 담기위한 변수
	var checkCols = "";
	var fullflag = false;
	var partialflag = false;
	// 체크된 체크박스 값을 가져온다
	
	checkbox.each(function(i) {
			checkCnt++;        //체크된 체크박스의 개수
			checkLast = i;     //체크된 체크박스의 인덱스
	});
 
	checkbox.each(function(i) {

		// checkbox.parent() : checkbox의 부모는 <td>이다.
		// checkbox.parent().parent() : <td>의 부모이므로 <tr>이다.
		var tr = checkbox.parent().parent().eq(i);
		var td = tr.children();
		
		// 체크된 row의 모든 값을 배열에 담는다.
		rowData.push(tr.text());
		if(checkCnt == 1){                            //체크된 체크박스의 개수가 한 개 일때,
			checkCols += td.eq(5).text();  
		}else{                                            //체크된 체크박스의 개수가 여러 개 일때,
			if(i == checkLast){                     //체크된 체크박스 중 마지막 체크박스일 때,
				checkCols += td.eq(5).text();  //'value'의 형태 (뒤에 ,(콤마)가 붙지않게)
			}else{
				checkCols += td.eq(5).text()+",";	 //'value',의 형태 (뒤에 ,(콤마)가 붙게)         			
			}
		}
		// 가져온 값을 배열에 담는다.
		tdArr.push(td.eq(5).text());
		//console.log(i + "="+td.eq(5).text()+" : "+td.eq(6).text());

		
	});
	//console.log("tdArr : " + tdArr);
	//alert(checkCols);
	$("#wizard_wherecol").html(checkCols);

	$('#listKeymap_dialog tr').each(function() {
   		var tr = $(this);
	 	var td = tr.children();
 		td.css("background-color", "#FFFFFF");
 		td.css("color", "#3B3B3B");
 		td.css("font-weight", "normal");
	});
	$('#listKeymap_dialog tr').each(function() {
   		var tr = $(this);
	 	var td = tr.children();
	 	var keys = td.eq(1).text().replace(/ /g, '').split(",");
	 	//console.log("keys ----- " + keys);
	 	for(var i in keys){
	 		if (i > tdArr.length - 1) break;

	 		//console.log("for(var i in keys) - "+i+"  "+keys[i] +"  "+tdArr[i] +" "+tdArr.length);
	 		//if (tdArr.length <= i+1){
		 		if(tdArr[i].match(keys[i])){
					fullflag = true;
					partialflag = true;
					//console.log("keys true - "+"  "+keys[i]);
				} else {
					 /** DGB캐피탈 에 적용을 위함 20231208*/
					if (tdArr[i] === "CUST_NO" || tdArr[i] === "CUSTNO") {
						tdArr[i] = "CUSTID";
						if(tdArr[i].match(keys[i])){
							fullflag = true;
							partialflag = true;
							//console.log("keys true - "+"  "+keys[i]);
						} else {
							fullflag = false;
							//console.log("keys false - "+"  "+keys[i]);
						}
					}
				}
	 		//}

        }
		// 조건을 만족하는 경우 스크롤 이동
		if (fullflag && partialflag) {
			var container = $('#listKeymap_dialog_table').parent();
			var trTop = tr.offset().top - container.offset().top; // 컨테이너 내부 상대 위치
			var containerHeight = container.height(); // 컨테이너의 높이
			var trHeight = tr.height(); // tr 요소의 높이

			// tr이 컨테이너 가운데에 오도록 스크롤 위치 계산
			var scrollTo = trTop - (containerHeight / 2) + (trHeight / 2);

			container.animate({
				scrollTop: scrollTo
			}, 500); // 500ms 동안 애니메이션 효과로 스크롤
		}


		if(fullflag && tdArr.length == keys.length) {
	 		td.focus();
	 		td.css("background-color", "#4E73DF");
	 		td.css("color", "white");
	 		td.css("font-weight", "bold");
/* 	 		//console.log("fullflag and tdArr.length == key.length");
	        var offset = td.offset();
	        $('html, body').animate({  : offset.top}, 400); */
	 	} else if(fullflag && tdArr.length != keys.length) {
	 		//td.focus();
	 		td.css("background-color", "#B7CBF7");
	 		td.css("color", "#3B3B3B");
	 		td.css("font-weight", "bold");
	 		//console.log("fullflag && tdArr.length != keys.length");
	 	} else if(partialflag){
	 		td.css("background-color", "#FFFFFF");
	 		td.css("color", "#3B3B3B");
	 		td.css("font-weight", "normal");
	 		//console.log("partialflag");
	 	}/*  else {
	 		td.css("background-color", "#FFFFFF");
	 		td.css("color", "#4BC243");
	 		td.css("font-weight", "normal");
	 	}  */
		fullflag = false;
		partialflag = false;

	});
	validateWizardApply();
}
function clickCheckSelectCol() {

	var rowData = new Array();
	var tdArr = new Array();
	var checkbox = $("input[name=checkselectcol]:checked");
	var checkCnt = 0;        //체크된 체크박스의 개수
	var checkLast = '';      //체크된 체크박스 중 마지막 체크박스의 인덱스를 담기위한 변수
	var checkCols = "";
	var fullflag = false;
	var partialflag = false;
	// 체크된 체크박스 값을 가져온다
	
	checkbox.each(function(i) {
			checkCnt++;        //체크된 체크박스의 개수
			checkLast = i;     //체크된 체크박스의 인덱스
	});
	checkbox.each(function(i) {
		// checkbox.parent() : checkbox의 부모는 <td>이다.
		// checkbox.parent().parent() : <td>의 부모이므로 <tr>이다.
		var tr = checkbox.parent().parent().eq(i);
		var td = tr.children();
		
		// 체크된 row의 모든 값을 배열에 담는다.
		rowData.push(tr.text());
		if(checkCnt == 1){                            //체크된 체크박스의 개수가 한 개 일때,
			checkCols += td.eq(5).text();  
		}else{                                            //체크된 체크박스의 개수가 여러 개 일때,
			if(i == checkLast){                     //체크된 체크박스 중 마지막 체크박스일 때,
				checkCols += td.eq(5).text();  //'value'의 형태 (뒤에 ,(콤마)가 붙지않게)
			}else{
				checkCols += td.eq(5).text()+",";	 //'value',의 형태 (뒤에 ,(콤마)가 붙게)         			
			}
		}
		if(i === 0){
			document.getElementById('selectedKeynameKr').value = td.eq(6).text();
		}
	});

	$("#wizard_selectcol").html(checkCols);
	validateWizardApply();
}
function clickRadio() {
	validateWizardApply();
}
function validateWizardApply() {
	var btn = document.getElementById('btnWizardApply');
	if (!btn) return;
	var hasKeymap = $('input[name=keymapradio]:checked').length > 0;
	var hasWherecol = $('input[name=checkwherecol]:checked').length > 0;
	var hasSelectcol = true;
	// GEN_KEYMAP step인 경우 checkselectcol 체크박스가 화면에 보이면 필수
	if ($('input[name=checkselectcol][type=checkbox]').length > 0) {
		hasSelectcol = $('input[name=checkselectcol][type=checkbox]:checked').length > 0;
	}
	if (hasKeymap && hasWherecol && hasSelectcol) {
		btn.disabled = false;
		btn.style.opacity = '1';
		btn.style.cursor = 'pointer';
	} else {
		btn.disabled = true;
		btn.style.opacity = '0.4';
		btn.style.cursor = 'not-allowed';
	}
}


</script>      
<script type="text/javascript">


$(document).ready(function() {

	var result = '<c:out value="${result}"/>';
	checkResultModal(result);
	history.replaceState({}, null, null);
	
 	$("button[data-oper='searchtable']").on("click", function(e){
		e.preventDefault();e.stopPropagation();
		SearchTableAction_wzd();
	}) 
	$("button[data-oper='applywizardresult']").on("click", function(e){
		e.preventDefault();e.stopPropagation();

		var db = $('#searchForm_wizard [name="search4"]').val();
		var owner = $('#searchForm_wizard [name="search5"]').val();
		var table_name = $('#searchForm_wizard [name="search6"]').val();

	    $('#piisteptable_modify_form [name="db"]').val(db);
		$('#piisteptable_modify_form [name="owner"]').val(owner);
		$('#piisteptable_modify_form [name="table_name"]').val(table_name);
		$('#steptabledb').text(db);
		$('#steptableowner').text(owner);
		$('#steptable_name').text(table_name);
		$('#piisteptable_modify_form [name="where_col"]').val($("#wizard_wherecol").text());
		
		var tr = jQuery("input[name=keymapradio]:checked").parent().parent();
		var td = tr.children();
		
		if(td.eq(2).text() == ''){
			alert("Select Keymap !!");
			return;
		}
		$('#piisteptable_modify_form [name="where_key_name"]').val(td.eq(2).text());//key_name
		
		var wherestr = "B.KEY_NAME = '"+td.eq(2).text()+"' AND B.KEYMAP_ID = '#KEYMAP_ID' AND B.BASEDATE = TO_DATE('#BASEDATE','yyyy/mm/dd')";//AND A.#WHERECOL1 = B.VAL1";
		var arr_cols = td.eq(1).text().split(",");
		var conindex = 0;
		for (var i = 0; i < arr_cols.length; i++) {
			conindex = i+1;
			wherestr += " AND A.#WHERECOL"+conindex+" = B.VAL"+conindex;
		}
		var checkboxwherecol = $("input[name=checkwherecol]:checked");
		var colseq = 1;
		checkboxwherecol.each(function(i) {
			var colname = checkboxwherecol.parent().parent().eq(i).children();
			wherestr = wherestr.replace("#WHERECOL"+colseq,colname.eq(5).text());
			colseq++;
		});
		
		if($('#piisteptable_modify_form [name="exetype"]').val() == "KEYMAP"){
			var key_name = $('#piisteptable_modify_form [name="key_name"]').val();
			var selectedKeynameKr = $('#piisteptable_modify_form [name="pk_col"]').val();
			var keymap_id = $('#piisteptable_modify_form [name="keymap_id"]').val();
			var seq3 = $('#piisteptable_modify_form [name="seq3"]').val();

			var key_cols = $("#wizard_selectcol").text();
			// key_name이 비어 있으면 "KEY_" + key_cols 값으로 설정
			if (!key_name) {
				key_name = "KEY_" + key_cols;
			}
			if (!selectedKeynameKr) {
				selectedKeynameKr = document.getElementById('selectedKeynameKr').value;
			}
			$('#piisteptable_modify_form [name="key_cols"]').val(key_cols);
			$('#piisteptable_modify_form [name="key_name"]').val(key_name);
			$('#piisteptable_modify_form [name="pk_col"]').val(selectedKeynameKr);
			var checkboxselectcol = $("input[name=checkselectcol]:checked");
			var colcnt = 1;
			var selectcols = "";
			var valcols = "";
			checkboxselectcol.each(function(i) {
				var colname = checkboxselectcol.parent().parent().eq(i).children();
				if(colcnt != 1) {selectcols += ", ";valcols += ", ";}
				selectcols += "A."+colname.eq(5).text();
				valcols += "VAL"+colcnt;
				colcnt++;
			});
			var selectstr = "SELECT '"+ keymap_id +"','"+ db +"','"
							+ key_name +
							"', TO_DATE('#BASEDATE','yyyy/mm/dd'), B.CUSTID, " + 
							selectcols
							+", B.EXPECTED_ARC_DEL_DATE FROM "+owner+"."+table_name+" A, COTDL.TBL_PIIKEYMAP B WHERE " + wherestr;
			
			$('#piisteptable_modify_form [name="wherestr"]').val(selectstr);

			if(seq3 == "1" || seq3 == "999")
				$('#piisteptable_modify_form [name="sqlstr"]').val("INSERT INTO COTDL.TBL_PIIKEYMAP(KEYMAP_ID, DB, KEY_NAME, BASEDATE, CUSTID, "+valcols+", EXPECTED_ARC_DEL_DATE) "+selectstr);
			else
				$('#piisteptable_modify_form [name="sqlstr"]').val("INSERT INTO COTDL.TBL_PIIKEYMAP_TMP(KEYMAP_ID, DB, KEY_NAME, BASEDATE, CUSTID, "+valcols+", EXPECTED_ARC_DEL_DATE) "+selectstr);
			
		}else if($('#piisteptable_modify_form [name="exetype"]').val() == "UPDATE"){
			var pk_col = $('#piisteptable_modify_form [name="pk_col"]').val();

			$('#piisteptable_modify_form [name="wherestr"]').val(wherestr);
			
			$('#piisteptable_modify_form [name="sqlstr"]').val("UPDATE "+owner+"."+table_name+" SET #UPDATECOLS WHERE ("+ pk_col + ") IN( SELECT A."+ pk_col.replace(/,/gi,",A.") +" from "+owner+"."+table_name+" A, COTDL.TBL_PIIKEYMAP B where "+wherestr + ")");
				
		}else{
			var pk_col = $('#piisteptable_modify_form [name="pk_col"]').val();

			$('#piisteptable_modify_form [name="wherestr"]').val(wherestr);
			
			$('#piisteptable_modify_form [name="sqlstr"]').val("DELETE FROM "+owner+"."+table_name+" WHERE ("+ pk_col + ") IN( SELECT A."+ pk_col.replace(/,/gi,",A.") +" from "+owner+"."+table_name+" A, COTDL.TBL_PIIKEYMAP B where "+wherestr + ")");
			
		}

		 $("#modalxl").modal("hide");
	
	})

});


SearchTableAction_wzd = function() {

	var pagenum = $('#searchForm_wizard [name="pagenum"]').val();
	var amount  = 50;//$('#searchForm_wizard [name="amount"]').val();
	var search1 = $('#searchForm_wizard [name="search1"]').val();
	var search2 = $('#searchForm_wizard [name="search2"]').val();
	var search3 = $('#searchForm_wizard [name="search3"]').val();
	var search4 = $('#searchForm_wizard [name="search4"]').val().toUpperCase();
	var search5 = $('#searchForm_wizard [name="search5"]').val().toUpperCase();
	var search6 = $('#searchForm_wizard [name="search6"]').val().toUpperCase();

	var url_search = "";
	var url_view = "modifydialog?"
				+"jobid="+search1+"&"
				+"version="+search2+"&"
				+"stepid="+search3+"&"
				;
	if (isEmpty(pagenum)) pagenum = 1;
	if (isEmpty(amount)) amount = 100;
	// search1, search2, search3 must be null for the new table
	//if (!isEmpty(search1)) {url_search += "&search1=" + search1};
	//if (!isEmpty(search2)) {url_search += "&search2=" + search2};
	//if (!isEmpty(search3)) {url_search += "&search3=" + search3};
	if (!isEmpty(search4)) {url_search += "&search4=" + search4};
	if (!isEmpty(search5)) {url_search += "&search5=" + search5};
	if (!isEmpty(search6)) {url_search += "&search6=" + search6};
	//alert("/piisteptable/"+url_view+"pagenum="+pagenum+"&amount="+amount+url_search);
	$.ajax({
		type : "GET", 
		url : "/piisteptable/" + url_view
				+ "pagenum=" + pagenum
				+ "&amount=" + amount
				+ url_search,
		dataType : "html",
		error: function(request, error){ ingHide();
			$("#errormodalbody").html(request.responseText);$("#errormodal").modal("show");
		},
		success: function(data){ ingHide();
			$('#modalxlbdoy').html(data);
		    //$("#modalxl").modal();
		}
	});
}
</script>


