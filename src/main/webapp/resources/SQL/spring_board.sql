----- **** 스프링 게시판 **** -----

show user;

create table spring_test1
(no         number
,name       varchar2(100)
,writeday   date default sysdate
);

select * from groupware_test;

select *
from spring_test1;

delete from tbl_comment
where no = 101;
commit;

select *
from tbl_board;


-------------------------------------------------------------------------

show user;
-- USER이(가) "HR"입니다.



select *
from tbl_member;

desc employees;

select employee_id, first_name || ' ' || last_name as ename, nvl( (salary + salary * commission_pct) * 12, salary * 12) as yearpay,
        case when substr(jubun, 7, 1) in ('1', '3') then '남' else '여' end as gender,
        extract (year from sysdate) - ( case when substr(jubun, 7, 1) in ('1', '2') then 1900 else 2000 end + to_number(substr(jubun, 1, 2)) ) + 1 as age
from employees
order by 1;




    ------- **** 게시판(답변글쓰기가 없고, 파일첨부도 없는) 글쓰기 **** -------
desc tbl_board;

create table tbl_board
(seq         number                not null    -- 글번호
,fk_userid   varchar2(20)          not null    -- 사용자ID
,name        varchar2(20)          not null    -- 글쓴이 
,subject     Nvarchar2(200)        not null    -- 글제목
,content     Nvarchar2(2000)       not null    -- 글내용   -- clob (최대 4GB까지 허용) 
,pw          varchar2(20)          not null    -- 글암호
,readCount   number default 0      not null    -- 글조회수
,regDate     date default sysdate  not null    -- 글쓴시간
,status      number(1) default 1   not null    -- 글삭제여부   1:사용가능한 글,  0:삭제된글
,constraint PK_tbl_board_seq primary key(seq)
,constraint FK_tbl_board_fk_userid foreign key(fk_userid) references tbl_member(userid)
,constraint CK_tbl_board_status check( status in(0,1) )
);

create sequence boardSeq
start with 1
increment by 1
nomaxvalue
nominvalue
nocycle
nocache;

select *
from tbl_board
order by seq desc;


-- 1개의 게시글의 (이전글, 다음글) 보기
select previousseq, previoussubject, seq, fk_userid, name, subject, content, readCount, regDate, nextseq, nextsubject
from
(
select    lag(seq,1) over(order by seq desc) as previousseq
            , lag(subject,1) over(order by seq desc) as previoussubject
            , seq, fk_userid, name, subject, content, readCount, to_char(regDate, 'yyyy-mm-dd hh24:mi:ss') as regDate
            , lead(seq,1) over(order by seq desc) as nextseq
            , lead(subject,1) over(order by seq desc) as nextsubject
from tbl_board
where status = 1
) V
where seq = 4;

------------------------------------------------------------------------
   ----- **** 댓글 게시판 **** -----

/* 
  댓글쓰기(tblComment 테이블)를 성공하면 원게시물(tblBoard 테이블)에
  댓글의 갯수(1씩 증가)를 알려주는 컬럼 commentCount 을 추가하겠다. 
*/

drop table tbl_board purge;
drop sequence boardSeq;

create table tbl_board
(seq         number                not null    -- 글번호
,fk_userid   varchar2(20)          not null    -- 사용자ID
,name        varchar2(20)          not null    -- 글쓴이 
,subject     Nvarchar2(200)        not null    -- 글제목
,content     Nvarchar2(2000)       not null    -- 글내용   -- clob (최대 4GB까지 허용) 
,pw          varchar2(20)          not null    -- 글암호
,readCount   number default 0      not null    -- 글조회수
,regDate     date default sysdate  not null    -- 글쓴시간
,status      number(1) default 1   not null    -- 글삭제여부   1:사용가능한 글,  0:삭제된글
,commentCount  number default 0  not null  -- 댓글의 갯수
,constraint PK_tbl_board_seq primary key(seq)
,constraint FK_tbl_board_fk_userid foreign key(fk_userid) references tbl_member(userid)
,constraint CK_tbl_board_status check( status in(0,1) )
);

create sequence boardSeq
start with 1
increment by 1
nomaxvalue
nominvalue
nocycle
nocache;


----- **** 댓글 테이블 생성 **** -----
create table tbl_comment
(seq           number               not null   -- 댓글번호
,fk_userid     varchar2(20)         not null   -- 사용자ID
,name          varchar2(20)         not null   -- 성명
,content       varchar2(1000)       not null   -- 댓글내용
,regDate       date default sysdate not null   -- 작성일자
,parentSeq     number               not null   -- 원게시물 글번호
,status        number(1) default 1  not null   -- 글삭제여부
                                               -- 1 : 사용가능한 글,  0 : 삭제된 글
                                               -- 댓글은 원글이 삭제되면 자동적으로 삭제되어야 한다.
,constraint PK_tbl_comment_seq primary key(seq)
,constraint FK_tbl_comment_userid foreign key(fk_userid)
                                    references tbl_member(userid)
,constraint FK_tbl_comment_parentSeq foreign key(parentSeq) 
                                      references tbl_board(seq) on delete cascade
,constraint CK_tbl_comment_status check( status in(1,0) ) 
);

create sequence commentSeq
start with 1
increment by 1
nomaxvalue
nominvalue
nocycle
nocache;

select *
from tbl_board
order by seq desc;

update tbl_board set commentcount = 0;
commit;

----- ===== Transaction 처리를 위한 시나리오 만들기 ===== -----
---- 회원들이 게시판에 글쓰기를 하면 글작성 1건당 point를 100점을 준다
---- 회원들이 게시판에 댓글쓰기를 하면 댓글작성 1건당 point를 50점을 준다
---- 그런데 point는 300점을 초과할 수 없다

-- tbl_member 테이블에 point 컬럼에 Check 제약을 추가
alter table tbl_member
add constraint CK_tbl_member_point check(point between 0 and 300);

insert into tbl_board(seq, fk_userid, name, subject, content, pw)
values(boardSeq.nextval, 'hjun34', '박수빈', '갓수시절로 돌아가자ㅏㅏ', '그때가 행복한거였어..', '0304');
commit;
update tbl_member set point = 301
where userid = 'hjun34';

-- 검색하기
select seq, fk_userid, name, subject, readCount, to_char(regDate, 'yyyy-mm-dd hh24:mi:ss') as regDate
		, commentCount
        from tbl_board
        where status = 1 and lower(subject) like '%' || lower('MY') || '%'
        order by seq desc;

select subject
from tbl_board
where status = 1 and lower(subject) like '%' || lower('MY') || '%';

--- 페이징 처리한 글목록 불러오기
select seq, fk_userid, name, subject, readCount, regDate, commentCount
from 
( 
select row_number() over(order by seq desc) as rno,
        seq, fk_userid, name, subject, readCount,
        to_char(regDate, 'yyyy-mm-dd hh24:mi:ss') as regDate,
        commentCount
from tbl_board
where status = 1
--and lower(subject) like '%' || lower('very') || '%'
) V
where rno between 1 and 10;

insert into tbl_comment(seq, fk_userid, name, content, parentseq)
values(commentSeq.nextval, 'eomjh', '엄정화', '됐겠지..?', 3);

update tbl_board set commentcount = 13
where seq = 3;

-- 댓글 페이징
select name, content, regDate
from
(
select row_number() over(order by seq desc) as rno, name, content, to_char(regDate, 'yyyy-mm-dd hh24:mi:ss')as regDate
from tbl_comment
where status = 1 and parentseq = 3
) V
where rno between 1 and 5;


-----------------------------------------------------------------------

------ ****** 댓글 및 답변글 및 파일첨부가 있는 게시판 ****** -------
drop table tbl_comment purge;
drop sequence commentSeq;
drop table tbl_board purge;
drop sequence boardSeq;


create table tbl_board
(seq         number                not null    -- 글번호
,fk_userid   varchar2(20)          not null    -- 사용자ID
,name        varchar2(20)          not null    -- 글쓴이 
,subject     Nvarchar2(200)        not null    -- 글제목
,content     Nvarchar2(2000)       not null    -- 글내용   -- clob (최대 4GB까지 허용) 
,pw          varchar2(20)          not null    -- 글암호
,readCount   number default 0      not null    -- 글조회수
,regDate     date default sysdate  not null    -- 글쓴시간
,status      number(1) default 1   not null    -- 글삭제여부   1:사용가능한 글,  0:삭제된글
,commentCount  number default 0  not null  -- 댓글의 갯수
,groupno        number                not null   -- 답변글쓰기에 있어서 그룹번호 
                                                 -- 원글(부모글)과 답변글은 동일한 groupno 를 가진다.
                                                 -- 답변글이 아닌 원글(부모글)인 경우 groupno 의 값은 groupno 컬럼의 최대값(max)+1 로 한다.

,fk_seq         number default 0      not null   -- fk_seq 컬럼은 절대로 foreign key가 아니다.!!!!!!
                                                 -- fk_seq 컬럼은 자신의 글(답변글)에 있어서 
                                                 -- 원글(부모글)이 누구인지에 대한 정보값이다.
                                                 -- 답변글쓰기에 있어서 답변글이라면 fk_seq 컬럼의 값은 
                                                 -- 원글(부모글)의 seq 컬럼의 값을 가지게 되며,
                                                 -- 답변글이 아닌 원글일 경우 0 을 가지도록 한다.

,depthno        number default 0       not null  -- 답변글쓰기에 있어서 답변글 이라면
                                                 -- 원글(부모글)의 depthno + 1 을 가지게 되며,
                                                 -- 답변글이 아닌 원글일 경우 0 을 가지도록 한다.

,fileName       varchar2(255)                    -- WAS(톰캣)에 저장될 파일명(20200725092715353243254235235234.png)                                       
,orgFilename    varchar2(255)                    -- 진짜 파일명(강아지.png)  // 사용자가 파일을 업로드 하거나 파일을 다운로드 할때 사용되어지는 파일명 
,fileSize       number                           -- 파일크기  
,constraint PK_tbl_board_seq primary key(seq)
,constraint FK_tbl_board_fk_userid foreign key(fk_userid) references tbl_member(userid)
,constraint CK_tbl_board_status check( status in(0,1) )
);

create sequence boardSeq
start with 1
increment by 1
nomaxvalue
nominvalue
nocycle
nocache;


create table tbl_comment
(seq           number               not null   -- 댓글번호
,fk_userid     varchar2(20)         not null   -- 사용자ID
,name          varchar2(20)         not null   -- 성명
,content       varchar2(1000)       not null   -- 댓글내용
,regDate       date default sysdate not null   -- 작성일자
,parentSeq     number               not null   -- 원게시물 글번호
,status        number(1) default 1  not null   -- 글삭제여부
                                               -- 1 : 사용가능한 글,  0 : 삭제된 글
                                               -- 댓글은 원글이 삭제되면 자동적으로 삭제되어야 한다.
,constraint PK_tbl_comment_seq primary key(seq)
,constraint FK_tbl_comment_userid foreign key(fk_userid)
                                    references tbl_member(userid)
,constraint FK_tbl_comment_parentSeq foreign key(parentSeq) 
                                      references tbl_board(seq) on delete cascade
,constraint CK_tbl_comment_status check( status in(1,0) ) 
);

desc tbl_board;

create sequence commentSeq
start with 1
increment by 1
nomaxvalue
nominvalue
nocycle
nocache;

begin
    for i in 101..200 loop
        insert into tbl_board(seq, fk_userid, name, subject, content, pw, readCount, regDate, status, groupno)
        values(boardSeq.nextval, 'eomjh', '엄정화', '엄정화 입니다'||i, '안녕하세요? 엄정화'|| i ||' 입니다.', '1234', default, default, default, i);
    end loop;
end;

select *
from tbl_board
order by seq desc;

---- **** 답변글쓰기는 일반회원은 불가하고 직원(관리자)들만 답변글쓰기가 가능하도록 한다 **** ----
select *
from tbl_member;

-- tbl_member 테이블에 gradelevel 이라는 컬럼을 추가
alter table tbl_member
add gradelevel number default 1;

-- *** 직원(관리자)들에게는 gradelevel 컬럼의 값을 10으로 부여. gradelevel 컬럼의 값이 10인 직원들만 답변글쓰기가 가능 *** --
update tbl_member set gradelevel = 10
where userid in('admin', 'hjun34');

--- *** 글번호 197에 대한 답변글쓰기를 한다라면 아래와같이 insert를 해야한다 *** ---
insert into tbl_board(seq, fk_userid, name, subject, content, pw, readCount, regDate, status, groupno, fk_seq, depthno)
values(boardSeq.nextval, 'admin', '관리자', '글번호 197에 대한 답변글 입니다.', '답변내용 입니다.', '1234', default, default, default, 197, 197, 1);
commit;
---- *** 답변글이 있을 시 글목록 보여주기 *** ---
select *
from tbl_board
order by seq desc;

--- *** 계층형 쿼리(답글형 게시판) *** ---
select seq, fk_userid, name, subject, readCount, regDate, commentCount, groupno, fk_seq, depthno
from 
(
    select rownum as rno, seq, fk_userid, name, subject, readCount, regDate, commentCount, groupno, fk_seq, depthno
    from 
    ( 
        select seq, fk_userid, name, subject, readCount,
                to_char(regDate, 'yyyy-mm-dd hh24:mi:ss') as regDate,
                commentCount, 
                groupno, fk_seq, depthno
        from tbl_board
        where status = 1
        start with fk_seq = 0
        connect by prior seq = fk_seq   -- connect by prior 다음에 나오는 컬럼 seq는  start with 되어지는 행의 컬럼이다
                                                     -- fk_seq는 start with 되어지는 행이 아닌 다른행에 존재하는 컬럼
        order siblings  by groupno desc, seq
        -- order siblings  by를 사용하는 이유는 그냥 정렬(order by)하면 계층구조가 깨진다
        -- 그래서 계층 구조를 그대로 유지하면서 동일한 가진 행끼리 정렬을 하려면 siblings를 써야만 한다
    ) V
) T
where rno between 1 and 10;

select * from tbl_member
where userid='admin';
update tbl_member set point = 0
where userid = 'hjun34';
commit;

--- *** tbl_member 테이블에 존재하는 제약조건 조회하기 *** ---
select *
from user_constraints
where table_name = 'TBL_MEMBER';
-- 제약조건 삭제
alter table tbl_member
drop constraint CK_TBL_MEMBER_POINT;

select *
from tbl_board