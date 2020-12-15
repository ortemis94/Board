package com.spring.employees.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.apache.poi.hssf.usermodel.HSSFDataFormat;
import org.apache.poi.ss.usermodel.BorderStyle;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.FillPatternType;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.HorizontalAlignment;
import org.apache.poi.ss.usermodel.IndexedColors;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.VerticalAlignment;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.streaming.SXSSFSheet;
import org.apache.poi.xssf.streaming.SXSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;

import com.spring.employees.service.InterEmpService;

@Controller
public class EmpController {

   @Autowired
   private InterEmpService service;

   @RequestMapping(value = "/emp/empList.action")
   public ModelAndView empList(HttpServletRequest request, ModelAndView mav) {

      // employees 테이블에서 근무중인 사원들의 부서번호 가져오기
      List<String> deptIdList = service.deptIdList();
      String sDeptIdes = request.getParameter("sDeptIdes");
      String gender = request.getParameter("gender");
      /*
       * gender ==> null 검색버튼을 클릭안하고 처음으로 보여줄때! gender ==> "" 성별을 선택했을때
       */

      // Object는 아무거나 다 담을것이다 라는 뜻!
      Map<String, Object> paraMap = new HashMap<String, Object>();

      if (sDeptIdes != null && !"".equals(sDeptIdes)) {
         String[] deptIdArr = sDeptIdes.split(",");
         paraMap.put("deptIdArr", deptIdArr);

         mav.addObject("sDeptIdes", sDeptIdes);
      }
      if (gender != null && !"".equals(gender)) {
         paraMap.put("gender", gender);
         mav.addObject("gender", gender);
      }

      List<Map<String, String>> empList = service.empList(paraMap);

      mav.addObject("deptIdList", deptIdList);
      mav.addObject("empList", empList);
      mav.setViewName("emp/empList.tiles2");

      return mav;
   }

   // Excel 파일로 다운받기
   @RequestMapping(value = "/excel/downloadExcelFile.action", method = { RequestMethod.POST })
   public String downloadExcelFile(HttpServletRequest request) {

      String sDeptIdes = request.getParameter("sDeptIdes");
      String gender = request.getParameter("gender");
      /*
       * gender ==> null 검색버튼을 클릭안하고 처음으로 보여줄때! gender ==> "" 성별을 선택했을때
       */

      // Object는 아무거나 다 담을것이다 라는 뜻!
      Map<String, Object> paraMap = new HashMap<String, Object>();

      if (sDeptIdes != null && !"".equals(sDeptIdes)) {
         String[] deptIdArr = sDeptIdes.split(",");
         paraMap.put("deptIdArr", deptIdArr);
      }
      if (gender != null && !"".equals(gender)) {
         paraMap.put("gender", gender);
      }

      List<Map<String, String>> empList = service.empList(paraMap);

      // 조회결과물인 empList를 가지고 엑셀 시트 생성하기
      // 시트를 생성하고, 행을 생성하고, 셀을 생성하고, 셀안에 내용을 넣어주면 된다.

      SXSSFWorkbook workbook = new SXSSFWorkbook();

      // 시트 생성
      SXSSFSheet sheet = workbook.createSheet("HR사원정보");

      // 시트 열 너비 설정
      sheet.setColumnWidth(0, 2000);
      sheet.setColumnWidth(1, 4000);
      sheet.setColumnWidth(2, 2000);
      sheet.setColumnWidth(3, 4000);
      sheet.setColumnWidth(4, 3000);
      sheet.setColumnWidth(5, 2000);
      sheet.setColumnWidth(6, 1500);
      sheet.setColumnWidth(7, 1500);

      // 행의 위치를 나타내는 변수
      int rowLocation = 0;

      ////////////////////////////////////////////////////////////////////////////////////////
      // CellStyle 정렬하기(Alignment)
      // CellStyle 객체를 생성하여 Alignment 세팅하는 메소드를 호출해서 인자값을 넣어준다.
      // 아래는 HorizontalAlignment(가로)와 VerticalAlignment(세로)를 모두 가운데 정렬 시켰다.
      CellStyle mergeRowStyle = workbook.createCellStyle();
      mergeRowStyle.setAlignment(HorizontalAlignment.CENTER);
      mergeRowStyle.setVerticalAlignment(VerticalAlignment.CENTER);
      // import org.apache.poi.ss.usermodel.VerticalAlignment 으로 해야함.

      CellStyle headerStyle = workbook.createCellStyle();
      headerStyle.setAlignment(HorizontalAlignment.CENTER);
      headerStyle.setVerticalAlignment(VerticalAlignment.CENTER);

      // CellStyle 배경색(ForegroundColor)만들기
      // setFillForegroundColor 메소드에 IndexedColors Enum인자를 사용한다.
      // setFillPattern은 해당 색을 어떤 패턴으로 입힐지를 정한다.
      mergeRowStyle.setFillForegroundColor(IndexedColors.DARK_BLUE.getIndex()); // IndexedColors.DARK_BLUE.getIndex()는 색상(남색)의 인덱스값을 리턴시켜준다.
      mergeRowStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);

      headerStyle.setFillForegroundColor(IndexedColors.LIGHT_YELLOW.getIndex()); // IndexedColors.LIGHT_YELLOW.getIndex()는 연한노랑의 인덱스값을 리턴시켜준다.
      headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
      
      // Cell 폰트(Font) 설정하기
        // 폰트 적용을 위해 POI 라이브러리의 Font 객체를 생성해준다.
        // 해당 객체의 세터를 사용해 폰트를 설정해준다. 대표적으로 글씨체, 크기, 색상, 굵기만 설정한다.
        // 이후 CellStyle의 setFont 메소드를 사용해 인자로 폰트를 넣어준다.
        Font mergeRowFont = workbook.createFont(); // import org.apache.poi.ss.usermodel.Font; 으로 한다.
        mergeRowFont.setFontName("나눔고딕");
        mergeRowFont.setFontHeight((short)500);
        mergeRowFont.setColor(IndexedColors.WHITE.getIndex());
        mergeRowFont.setBold(true);
                
        mergeRowStyle.setFont(mergeRowFont); 
        
        // CellStyle 테두리 Border
        // 테두리는 각 셀마다 상하좌우 모두 설정해준다.
        // setBorderTop, Bottom, Left, Right 메소드와 인자로 POI라이브러리의 BorderStyle 인자를 넣어서 적용한다.
        headerStyle.setBorderTop(BorderStyle.THICK);
        headerStyle.setBorderBottom(BorderStyle.THICK);
        headerStyle.setBorderLeft(BorderStyle.THIN);
        headerStyle.setBorderRight(BorderStyle.THIN);
        
        // Cell Merge 셀 병합시키기
        /* 셀병합은 시트의 addMergeRegion 메소드에 CellRangeAddress 객체를 인자로 하여 병합시킨다.
           CellRangeAddress 생성자의 인자로(시작 행, 끝 행, 시작 열, 끝 열) 순서대로 넣어서 병합시킬 범위를 정한다. 배열처럼 시작은 0부터이다.  
        */
        Row mergeRow = sheet.createRow(rowLocation);
        
        // 병합할 행에 "우리회사 사원정보"로 셀을 만들어 셀에 스타일을 주기
        for(int i=0; i<8; i++) {
           Cell cell = mergeRow.createCell(i);
           cell.setCellStyle(mergeRowStyle);
           cell.setCellValue("우리회사 사원정보");
        }
        
        // 셀 병합하기
        sheet.addMergedRegion(new CellRangeAddress(rowLocation, rowLocation, 0, 7)); //시작 행, 끝행, 시작 열, 끝 열
        
        // CellStyle 천단위 쉼표, 금액
        CellStyle moneyStyle = workbook.createCellStyle();
        moneyStyle.setDataFormat(HSSFDataFormat.getBuiltinFormat("#,##0"));
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        // 헤더 행 생성
        Row headerRow = sheet.createRow(++rowLocation); // 엑셀에서 행의 시작은 0부터 시작한다.
                                            // ++rowLocation은 전위연산자임.
        
     // 해당 행의 첫번째 열 셀 생성
        Cell headerCell = headerRow.createCell(0); // 엑셀에서 열의 시작은 0 부터 시작한다.
        headerCell.setCellValue("부서번호");
        headerCell.setCellStyle(headerStyle);
        
        // 해당 행의 두번째 열 셀 생성
        headerCell = headerRow.createCell(1);
        headerCell.setCellValue("부서명");
        headerCell.setCellStyle(headerStyle);
        
        // 해당 행의 세번째 열 셀 생성
        headerCell = headerRow.createCell(2);
        headerCell.setCellValue("사원번호");
        headerCell.setCellStyle(headerStyle);
        
        // 해당 행의 네번째 열 셀 생성
        headerCell = headerRow.createCell(3);
        headerCell.setCellValue("사원명");
        headerCell.setCellStyle(headerStyle);
        
        // 해당 행의 다섯번째 열 셀 생성
        headerCell = headerRow.createCell(4);
        headerCell.setCellValue("입사일자");
        headerCell.setCellStyle(headerStyle);
        
        // 해당 행의 여섯번째 열 셀 생성
        headerCell = headerRow.createCell(5);
        headerCell.setCellValue("월급");
        headerCell.setCellStyle(headerStyle);
        
        // 해당 행의 일곱번째 열 셀 생성
        headerCell = headerRow.createCell(6);
        headerCell.setCellValue("성별");
        headerCell.setCellStyle(headerStyle);
        
        // 해당 행의 여덟번째 열 셀 생성
        headerCell = headerRow.createCell(7);
        headerCell.setCellValue("나이");
        headerCell.setCellStyle(headerStyle);
        
        // HR사원정보 내용에 해당하는 행 및 셀 생성하기
        Row bodyRow = null;
        Cell bodyCell = null;
        
        for (int i = 0; i < empList.size(); i++) {
         
           Map<String, String> empMap = empList.get(i);
           
           // 행 생성
           bodyRow = sheet.createRow( i + (rowLocation + 1) );
           
           // 데이터 부서번호 표시
           bodyCell = bodyRow.createCell(0);
           bodyCell.setCellValue(empMap.get("department_id"));
           
           // 데이터 부서명 표시
           bodyCell = bodyRow.createCell(1);
           bodyCell.setCellValue(empMap.get("department_name"));
           
           // 데이터 사원번호 표시
           bodyCell = bodyRow.createCell(2);
           bodyCell.setCellValue(empMap.get("employee_id"));
           
           // 데이터 사원명 표시
           bodyCell = bodyRow.createCell(3);
           bodyCell.setCellValue(empMap.get("fullname"));
           
           // 데이터 입사일자 표시
           bodyCell = bodyRow.createCell(4);
           bodyCell.setCellValue(empMap.get("hire_date"));
           
           // 데이터 월급 표시
           bodyCell = bodyRow.createCell(5);
           bodyCell.setCellValue(empMap.get("monthsal"));
           
           // 데이터 성별 표시
           bodyCell = bodyRow.createCell(6);
           bodyCell.setCellValue(empMap.get("gender"));
           
           // 데이터 나이 표시
           bodyCell = bodyRow.createCell(7);
           bodyCell.setCellValue(empMap.get("age"));
           
      }// end of for-------------------------
        
        
      return "excelDownloadView";
   }

}