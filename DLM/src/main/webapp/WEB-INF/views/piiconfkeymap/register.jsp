<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>


<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %> 
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<!-- Begin Page Content -->
<div class="card shadow m-1 " style="height:818px">
	<!-- Page Heading -->

	<div class="card shadow mb-4">
			<div class="card-header text-right">
				<sec:authentication property="principal" var="pinfo"/>
		  		<sec:authorize access="isAuthenticated()">
				  <button data-oper='register' class="btn btn-primary btn-sm pt-0 pb-2 button"><spring:message code="btn.register" text="Register"/></button>
				</sec:authorize>
				  <button data-oper='list' class="btn btn-secondary btn-sm pt-0 pb-2 button">List</button>
			</div>

		<div class="row  ml-1">
			<div class="col-lg-12">
				<div class="panel panel-default">

					<div class="panel-heading"> </div>
					<div class="panel-body">

						<form style="margin: 0; padding: 0;" role="form" id="piiconftable_register_form" action="/piiconftable/register" method="post">
						
							<div class="form-row ">
							<div class="form-row ">
							<div class="form-group col-sm-12"><label for="inputinsertstr">Keymap_id</label><input type="text" class="form-control form-control-sm" id="inputkeymap_id" autofocus name='keymap_id' value='<c:out value="${piiconfkeymap.keymap_id}"/>' ></div>
							</div>
							<div class="form-group col-sm-2"><label for="inputpiikeyno">Piikeyno</label><input type="text" class="form-control form-control-sm" id="inputpiikeyno" name='piikeyno' value='<c:out value="${piiconftable.piikeyno}"/>'  readonly="readonly"></div>
							<div class="form-group col-sm-2"><label for="inputkey_name">Key_Name</label><input type="text" class="form-control form-control-sm" id="inputkey_name" name='key_name' value='<c:out value="${piiconftable.key_name}"/>' ></div>
							<div class="form-group col-sm-2"><label for="inputdb">Db</label><input type="text" class="form-control form-control-sm" id="inputdb" name='db' value='<c:out value="${piiconftable.db}"/>' ></div>
							<div class="form-group col-sm-1"><label for="inputseq1">Seq1</label><input type="text" class="form-control form-control-sm" id="inputseq1" name='seq1' value='<c:out value="${piiconftable.seq1}"/>' ></div>
							<div class="form-group col-sm-1"><label for="inputseq2">Seq2</label><input type="text" class="form-control form-control-sm" id="inputseq2" name='seq2' value='<c:out value="${piiconftable.seq2}"/>' ></div>
							<div class="form-group col-sm-1"><label for="inputseq3">Seq3</label><input type="text" class="form-control form-control-sm" id="inputseq3" name='seq3' value='<c:out value="${piiconftable.seq3}"/>' ></div>
							</div>
							<div class="form-row ">
							<div class="form-group col-sm-3"><label for="inputkey_cols">Key_Cols</label><input type="text" class="form-control form-control-sm" id="inputkey_cols" name='key_cols' value='<c:out value="${piiconftable.key_cols}"/>' ></div>
							<div class="form-group col-sm-3"><label for="inputsrc_owner">Src_Owner</label><input type="text" class="form-control form-control-sm" id="inputsrc_owner" name='src_owner' value='<c:out value="${piiconftable.src_owner}"/>' ></div>
							<div class="form-group col-sm-3"><label for="inputsrc_table_name">Src_Table_Name</label><input type="text" class="form-control form-control-sm" id="inputsrc_table_name" name='src_table_name' value='<c:out value="${piiconftable.src_table_name}"/>' ></div>
							</div>
							<div class="form-row ">
							<div class="form-group col-sm-3"><label for="inputwhere_col">Where_Col</label><input type="text" class="form-control form-control-sm" id="inputwhere_col" name='where_col' value='<c:out value="${piiconftable.where_col}"/>' ></div>
							<div class="form-group col-sm-3"><label for="inputwhere_key_name">Where_Key_name</label><input type="text" class="form-control form-control-sm" id="inputwhere_key_name" name='where_key_name' value='<c:out value="${piiconftable.where_key_name}"/>' ></div>
							<div class="form-group col-sm-1"><label for="inputparallelcnt">ParallelCnt</label><input type="text" class="form-control form-control-sm" id="inputparallelcnt" name='parallelcnt' value='<c:out value="${piiconftable.parallelcnt}"/>' ></div>
							<div class="form-group col-sm-1"><label for="inputstatus">Status</label><input type="text" class="form-control form-control-sm" id="inputstatus" name='status' value='<c:out value="${piiconftable.status}"/>' ></div>
							<div class="form-group col-sm-1"><label for="inputsqltype">Sqltype</label><input type="text" class="form-control form-control-sm" id="inputsqltype" name='sqltype' value='<c:out value="${piiconftable.sqltype}"/>' ></div>
							</div>
							<div class="form-row ">
							<div class="form-group col-sm-12"><label for="inputinsertstr">Insertstr</label><input type="text" class="form-control form-control-sm" id="inputinsertstr" name='insertstr' value='<c:out value="${piiconftable.insertstr}"/>' ></div>
							</div>
							<div class="form-row ">
							<div class="form-group col-sm-12"><label for="inputwherestr">Wherestr</label><textarea spellcheck="false" rows="5" class="form-control form-control-sm" id="inputwherestr" name='wherestr' ><c:out value="${piiconftable.wherestr}"/></textarea></div>
							</div>
							<div class="form-row ">
							<div class="form-group col-sm-12"><label for="inputrefstr">Refstr</label><textarea spellcheck="false" rows="2" class="form-control form-control-sm" id="inputrefstr" name='refstr' ><c:out value="${piiconftable.refstr}"/></textarea></div>
							</div>

							<input type="hidden" name='regdate' value='' >
							<input type="hidden" name='upddate' value='' >

							<input type="hidden" name="reguserid" value='<sec:authentication property="principal.member.userid"/>' />
							<input type="hidden" name="upduserid" value='<sec:authentication property="principal.member.userid"/>' />
							<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
						</form>

					<div id="register_result"></div>
				  </div><!--  end panel-body -->
				  
				</div><!--  panel panel-default-->
			</div><!-- col-lg-12 -->
		</div><!-- row  ml-1 -->
	</div>	<!-- <div class="card shadow mb-4"> DataTales begin-->
</div><!-- <div class="container-fluid"> -->

<script type="text/javascript">
	$(function(){
	    $("#menupath").html(Menupath +">"+"<spring:message code="memu.keymap" text="ConfKeymap management"/>" +">Register");
	});
	$(document).ready(function() {
	  
	  $("button[data-oper='register']").on("click", function(e){ 

	 	var elementForm = $("#piiconftable_register_form");
		var elementResult = $("#content_home"); 
	     $.ajax({
	        type : "POST", 
	        url : "/piiconftable/register",
	        dataType : "html",
	        //data:$('form').serialize(), 
	        data:elementForm.serialize(),
	        error: function(request, error){ ingHide();
	            $("#errormodalbody").html(request.responseText);$("#errormodal").modal("show");//alert("code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
	        },
	        success: function(data){ ingHide();
	        	elementResult.html(data); //받아온 data 실행
	            //elementResult.text(Parse_data); //받아온 data 실행
	        }    
	    });

	  });
	  
	  $("button[data-oper='list']").on("click", function(e){
	    
		 $('#content_home').load("/piiconftable/list");

	  });  
	  	  
	});
</script>