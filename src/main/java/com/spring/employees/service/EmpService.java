package com.spring.employees.service;

import java.util.*;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.spring.employees.model.InterEmpDAO;

@Service
public class EmpService implements InterEmpService {

	@Autowired
	private InterEmpDAO dao;

	
	// employees 테이블에서 근무중인 사원들의 부서번호 가져오기
	@Override
	public List<String> deptIdList() {
		List<String> deptIdList = dao.deptIdList();
		return deptIdList;
	}


	// employees 테이블에서 조건에 만족하는 사원들을 가져오기
	@Override
	public List<Map<String, String>> empList(Map<String,Object> paraMap) {
		List<Map<String, String>> empList = dao.empList(paraMap);
		return empList;
	}

	
}
