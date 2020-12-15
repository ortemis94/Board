package com.spring.employees.model;

import java.util.*;

public interface InterEmpDAO {

	List<String> deptIdList(); 
	// employees 테이블에서 근무중인 사원들의 부서번호 가져오기 

	List<Map<String, String>> empList(Map<String,Object> paraMap);
	// employees 테이블에서 조건에 만족하는 사원들을 가져오기
	
}
