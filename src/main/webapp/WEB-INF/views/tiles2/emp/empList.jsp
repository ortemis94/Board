<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<style type="text/css">
	
	#mycontainer {
		width: 95%;
		margin: 10px auto;
	}
	
	table {
		width: 80%;
	}
	
	table, th, td {
		border: solid 1px gray;
		border-collapse: collapse;
	}
	
	th {
		text-align: center;
		background-color: #ccc;
	}
	
	form {
		margin: 0 0 30px 0;
	}
	
</style>

<script type="text/javascript">
	$(document).ready(function(){
		
	   // 검색버튼 클릭시 
	   $("button#btnSearch").click(function(){
		   
		   var arrDeptId = new Array();
		   
		   $("input:checkbox[name=deptId]").each(function(){
			   var bool = $(this).is(":checked"); // 체크박스의 체크유무 검사 
		       if(bool == true) {
		    	   // 체크박스에 체크가 되었으면 
		    	   arrDeptId.push($(this).val());
		       }
		   });
		   
		   var sDeptIdes = arrDeptId.join();
		   // console.log("~~~~~ 확인용  sDeptIdes => " + sDeptIdes);
		   /*
		   		~~~~~ 확인용  sDeptIdes => -9999,50,110
		   		~~~~~ 확인용  sDeptIdes => 
		   		~~~~~ 확인용  sDeptIdes => 10,30,50,80,110
		   */
		   
		   var frm = document.searchFrm;
		   frm.sDeptIdes.value = sDeptIdes;
		   
		   frm.method = "GET";
		   frm.action = "empList.action";
		   frm.submit();
	   });
	   
	   //// === 체크박스 유지시키지 시작 === ////
	   var sDeptIdes = "${sDeptIdes}";
	   // console.log(sDeptIdes); // -9999,50,110
	   
	   if(sDeptIdes != "") {
		  var arrDeptId = sDeptIdes.split(","); 
		  // [-9999,50,110]
		  
		  $("input:checkbox[name=deptId]").each(function(){
			  for(var i=0; i<arrDeptId.length; i++) {
				  if($(this).val() == arrDeptId[i]) {
					  $(this).prop("checked", true);
					  break;
				  }
			  }
		  });
		  
	   }
	   //// === 체크박스 유지시키지 끝 === ////
	   
	   
	   //// === 성별 유지시키지 시작 === ////
	   var gender = "${gender}";
	   if(gender != "") {
		   $("select#gender").val(gender);
	   }
	   //// === 성별 유지시키지 끝 === ////
	   
	   
	   ///// === Excel 파일로 다운받기 시작 === /////
	   $("button#btnExcel").click(function() {
		   var arrDeptId = new Array();
		   
		   $("input:checkbox[name=deptId]").each(function(){
			   var bool = $(this).is(":checked"); // 체크박스의 체크유무 검사 
		       if(bool == true) {
		    	   // 체크박스에 체크가 되었으면 
		    	   arrDeptId.push($(this).val());
		       }
		   });
		   
		   var sDeptIdes = arrDeptId.join();
		   // console.log("~~~~~ 확인용  sDeptIdes => " + sDeptIdes);
		   /*
		   		~~~~~ 확인용  sDeptIdes => -9999,50,110
		   		~~~~~ 확인용  sDeptIdes => 
		   		~~~~~ 확인용  sDeptIdes => 10,30,50,80,110
		   */
		   
		   var frm = document.searchFrm;
		   frm.sDeptIdes.value = sDeptIdes;
		   
		   frm.method = "POST";
		   frm.action = "<%= request.getContextPath() %>/excel/downloadExcelFile.action";
		   frm.submit();
	   });
	   
	   ///// === Excel 파일로 다운받기 끝 === /////
	   
	});// end of $(document).ready()----------------------
</script>

<div id="mycontainer" align="center">
	
	<form name="searchFrm">
		<c:if test="${not empty deptIdList}">
			<c:forEach var="deptId" items="${deptIdList}" varStatus="status"> 
				 <label for="${status.index}">
				 	<c:if test="${deptId == -9999}">부서없음</c:if>
				 	<c:if test="${deptId != -9999}">${deptId}</c:if>
				 </label>&nbsp;
				<input type="checkbox" name="deptId" id="${status.index}" value="${deptId}" />&nbsp;&nbsp;
			</c:forEach>
		</c:if>
		<input type="hidden" name="sDeptIdes" />
		<br/>
		<select name="gender" id="gender" style="height: 25px; width: 60px; margin: 10px 20px 0 0;">
			<option value="">성별</option>
			<option>남</option>
			<option>여</option>
		</select>
		<button type="button" id="btnSearch">검색</button>
		&nbsp;&nbsp;
		<button type="button" id="btnExcel">Excel파일로 저장</button>
		
	</form>
	
	<br/>
	
	<table>
		<thead>
			<tr>
				<th>부서번호</th>
				<th>부서명</th>
				<th>사원번호</th>
				<th>사원명</th>
				<th>입사일자</th>
				<th>월급</th>
				<th>성별</th>
				<th>나이</th>
			</tr>
		</thead>
		<tbody>
		<c:if test="${not empty empList}">
			<c:forEach var="map" items="${empList}">
				<tr>
					<td style="text-align: center;">${map.department_id}</td>
					<td>${map.department_name}</td>
					<td style="text-align: center;">${map.employee_id}</td>
					<td>${map.fullname}</td>
					<td style="text-align: center;">${map.hire_date}</td>
					<td style="text-align: right;"><fmt:formatNumber value="${map.monthsal}" pattern="#,###" /></td>     
					<td style="text-align: center;">${map.gender}</td>
					<td style="text-align: center;">${map.age}</td>
				</tr>
			</c:forEach>
		</c:if>
		</tbody>
	</table>
</div>


