package com.spring.employees.model;

import java.util.*;

import javax.annotation.Resource;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class EmpDAO implements InterEmpDAO {

	@Resource
	private SqlSessionTemplate sqlsession3;

	
	// employees 테이블에서 근무중인 사원들의 부서번호 가져오기
	@Override
	public List<String> deptIdList() {
		List<String> deptIdList = sqlsession3.selectList("emp.deptIdList");
		return deptIdList;
	}


	// employees 테이블에서 조건에 만족하는 사원들을 가져오기
	@Override
	public List<Map<String, String>> empList(Map<String,Object> paraMap) {
		List<Map<String, String>> empList = sqlsession3.selectList("emp.empList", paraMap);
		return empList;
	}
	
	
}
